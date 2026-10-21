#!/usr/bin/env python3
"""CAFM Phase 1 safe merge installer: preflight first, then backup and apply.

Requires the already repaired iOS 17.6 project, Python3, Git (Xcode CLI).
Never silently discards local edits, overwrites on a conflict, or changes Pods.
"""
import datetime
import hashlib
import json
import os
import plistlib
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

SCRIPT=Path(__file__).resolve()
ROOT=SCRIPT.parent.parent  # /project/_phase1_merge/install.py -> /project
PAYLOAD=ROOT/'_phase1_merge'/'payload'
BASE=ROOT/'_phase1_merge'/'reference_original'
MANIFEST=ROOT/'_phase1_merge'/'manifest.json'
PROJ=ROOT/'cafm.xcodeproj'/'project.pbxproj'
DRY='--check' in sys.argv or '--dry-run' in sys.argv

def fail(message):
    print('\nSTOPPED: '+message,file=sys.stderr)
    print('No Phase 1 source/project changes were made. Do not force an overwrite.',file=sys.stderr)
    raise SystemExit(1)

def digest(data): return hashlib.sha256(data).hexdigest()
def norm(data): return data.replace(b'\r\n',b'\n').replace(b'\r',b'\n')
def newline_for(data):
    return b'\r\n' if data.count(b'\r\n') > 0 and data.count(b'\r\n') * 2 >= data.count(b'\n') else b'\n'
def unix_to_eol(data,eol): return norm(data).replace(b'\n',eol)

def make_merge(existing,original,new,rel):
    # line-ending-only differences should not prevent installing Phase 1
    local=norm(existing)
    base=norm(original)
    desired=norm(new)
    if local == desired: return None,'already Phase 1'
    if local == base: return unix_to_eol(new,newline_for(existing)),'original content (install)'
    # Three-way merge. No source modified until ALL files preflight successfully.
    with tempfile.TemporaryDirectory(prefix='cafm-merge-') as directory:
        td=Path(directory)
        our=td/'current'; anc=td/'original'; their=td/'phase1'
        our.write_bytes(local); anc.write_bytes(base); their.write_bytes(desired)
        result=subprocess.run(['git','merge-file','-p','--diff3',str(our),str(anc),str(their)],capture_output=True)
        if result.returncode!=0 or b'<<<<<<< ' in result.stdout or b'>>>>>>> ' in result.stdout:
            fail('Conflicting or unexpected local changes in '+rel+'. Your source was preserved. Upload this file so we can merge it manually.')
        merged=unix_to_eol(result.stdout,newline_for(existing))
        if norm(merged)==local: return None,'already contains equivalent changes'
        return merged,'merged with local edits'

def update_project(original, rows):
    text=original.decode('utf-8')
    versions=re.findall(r'\bIPHONEOS_DEPLOYMENT_TARGET\s*=\s*([^;\s]+)',text)
    if not versions or any(x!='17.6' for x in versions):
        fail('Project does not consistently target iOS 17.6. Run fix_cafm_ios_17_6.command first.')
    anchors={
      'PBXBuildFile':('/* End PBXBuildFile section */',False),
      'PBXFileReference':('/* End PBXFileReference section */',False),
      'SettingsGroup':('\t\t\t\t962EC1302C7651A6001EE1B9 /* SettingsVC.swift */,',True),
      'SourcesBuildPhase':('\t\t\t\t962EC1312C7651A6001EE1B9 /* SettingsVC.swift in Sources */,',True),
    }
    for group,(anchor,after) in anchors.items():
        items=list(reversed(rows[group])) if after else rows[group]
        for line in items:
            marker=line.rstrip('\n')
            if marker in text: continue
            if text.count(anchor)!=1:
                fail('Cannot locate unique Xcode project insertion point for '+group+'.')
            if after:
                text=text.replace(anchor,anchor+'\n'+marker,1)
            else:
                text=text.replace(anchor,line+anchor,1)
    for group,lines in rows.items():
        for line in lines:
            if text.count(line.rstrip('\n'))!=1:
                fail('Project references contain unexpected duplicates for '+line.strip())
    # Avoid introducing dangling build file refs if the group paths or build phase structure changed.
    with tempfile.TemporaryDirectory(prefix='cafm-project-lint-') as d:
        tmp=Path(d)/'project.pbxproj'; tmp.write_text(text,encoding='utf-8')
        if shutil.which('plutil'):
            proc=subprocess.run(['plutil','-lint',str(tmp)],capture_output=True,text=True)
            if proc.returncode:
                fail('Merged Xcode project failed plutil validation: '+proc.stdout+proc.stderr)
    return text.encode('utf-8')

def main():
    if not MANIFEST.exists(): fail('Package is incomplete: manifest missing.')
    if not (ROOT/'cafm.xcworkspace').is_dir() or not (ROOT/'Podfile').is_file() or not PROJ.is_file():
        fail('Run from the project directory containing cafm.xcworkspace, cafm.xcodeproj and Podfile. Expected /Users/Amjad/Desktop/cafm/cafm.')
    if not shutil.which('git'): fail('Git command is required for safe three-way merging.')
    m=json.loads(MANIFEST.read_text('utf-8'))
    planned={}; status=[]
    existing_set=set(m['existing'])
    new_set=set(m['new'])
    for relative in m['files']:
        desired_path=PAYLOAD/relative
        if not desired_path.is_file(): fail('Missing Phase 1 payload '+relative)
        desired=desired_path.read_bytes()
        if digest(desired)!=m['phase1_hashes'][relative]: fail('Phase 1 payload checksum mismatch: '+relative)
        dst=ROOT/relative
        if relative in existing_set:
            baseline=BASE/relative
            if not baseline.is_file() or digest(baseline.read_bytes())!=m['original_hashes'][relative]:
                fail('Original reference file missing or altered: '+relative)
            if not dst.is_file(): fail('Cannot find existing application source '+relative)
            merged,description=make_merge(dst.read_bytes(),baseline.read_bytes(),desired,relative)
        elif relative in new_set:
            if dst.is_file():
                if norm(dst.read_bytes())==norm(desired):
                    merged,description=None,'already Phase 1'
                else: fail('Unexpected existing Phase 1 component '+relative+'. Upload it for inspection.')
            else: merged,description=desired,'new component'
        else: fail('Invalid manifest category: '+relative)
        if merged is not None:
            planned[dst]=merged
        status.append((relative,description))

    # Detect likely half-applied changes to the app bootstrap; do not duplicate it.
    app=planned.get(ROOT/'cafm/AppDelegate/AppDelegate.swift', (ROOT/'cafm/AppDelegate/AppDelegate.swift').read_bytes())
    if norm(app).count(b'ServerConfiguration.shared.bootstrap()')!=1:
        fail('AppDelegate has an unexpected number of server bootstraps after merging.')

    plist_path=ROOT/'cafm/Info.plist'
    try:
        p=plistlib.loads(planned.get(plist_path,plist_path.read_bytes()))
        if p.get('CAFMDefaultAPIBaseURL')!='https://app.corecafm.com':
            fail('Info.plist is missing or has a conflicting default server value.')
    except Exception as ex: fail('Info.plist is not valid: '+str(ex))

    # Syntax-check each changed Swift file before touching the real project.
    # This does not replace Xcode compilation, but catches malformed automatic merges.
    if shutil.which('swiftc'):
        for dst,data in planned.items():
            if dst.suffix!='.swift': continue
            with tempfile.TemporaryDirectory(prefix='cafm-swift-parse-') as d:
                tmp=Path(d)/dst.name
                tmp.write_bytes(data)
                proc=subprocess.run(['swiftc','-frontend','-parse',str(tmp)],capture_output=True,text=True)
                if proc.returncode!=0:
                    fail('Swift parse check failed for '+str(dst.relative_to(ROOT))+': '+(proc.stderr or proc.stdout)[:900])

    new_project=update_project(PROJ.read_bytes(),m['project_lines'])
    if new_project!=PROJ.read_bytes(): planned[PROJ]=new_project

    print('CAFM Phase 1 preflight — '+ ('CHECK ONLY' if DRY else 'SAFE INSTALL'))
    print('Project:',ROOT)
    for rel,reason in status: print(' ',rel+':',reason)
    print('Xcode project:', 'add Phase 1 references' if PROJ in planned else 'already configured')
    print('Files to write:',len(planned))
    if DRY:
        print('Check passed. No files changed. Run bash ./install_phase1_merge.command --apply to install.')
        return
    if not planned:
        print('Phase 1 is already installed; nothing changed.')
        return
    stamp=datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
    backup=ROOT/('.cafm-phase1-merge-backup-'+stamp)
    # Preserve existing file contents and the project file BEFORE writing any changes.
    for dst in planned:
        if dst.is_file():
            saved=backup/dst.relative_to(ROOT)
            saved.parent.mkdir(parents=True,exist_ok=True)
            shutil.copy2(dst,saved)
    backup.mkdir(exist_ok=True)
    (backup/'INSTALL_MANIFEST.txt').write_text('\n'.join(f'{k.relative_to(ROOT)}\t{digest(v)}' for k,v in planned.items())+'\n',encoding='utf-8')
    for dst,data in planned.items():
        dst.parent.mkdir(parents=True,exist_ok=True)
        # Atomic per-file replacement after complete preflight+backup.
        with tempfile.NamedTemporaryFile(prefix='.cafmtmp-',dir=dst.parent,delete=False) as f:
            f.write(data); tmp=Path(f.name)
        if dst.exists():
            shutil.copymode(dst,tmp)
        os.replace(tmp,dst)
    print('Phase 1 installed. Files updated:',len(planned))
    print('Backup:',backup)
    print('iOS deployment target remains 17.6; no Podfile/Pods settings were changed.')
    print('Open cafm.xcworkspace, Clean Build Folder, then Build and run as Admin.')

if __name__=='__main__': main()
