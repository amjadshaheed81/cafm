#!/usr/bin/env python3
"""Safe, local-only CAFM iOS Monthly Audit asset filtering patch.

Runs from /Users/Amjad/Desktop/cafm/cafm (Xcode project root).
Updates ONLY MonthlyAuditQuestionResponseVC.swift; refuses conflicts.
"""
import argparse, json, sys, os, shutil, tempfile, datetime
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--check', action='store_true', help='dry-run, write nothing')
parser.add_argument('--apply', action='store_true', help='create backup and apply patch')
args=parser.parse_args()
if args.check == args.apply:
    parser.error('Choose --check or --apply')
project = Path.cwd()
target = project / 'cafm/Controller/SiteCheck/MonthlyAudit/MonthlyAuditQuestionResponseVC.swift'
manifest = Path(__file__).with_name('replacements.json')
if not (project / 'cafm.xcworkspace').exists() or not target.is_file() or not manifest.is_file():
    sys.exit('ERROR: Run from Xcode project root with cafm.xcworkspace and the extracted installer present.')
raw=target.read_bytes()
try:
    original=raw.decode('utf-8')
except UnicodeDecodeError:
    sys.exit('ERROR: Swift file is not UTF-8; no changes made.')
endings='\r\n' if b'\r\n' in raw else '\n'
s=original.replace('\r\n','\n')
changes=json.loads(manifest.read_text(encoding='utf-8'))
changed=0
for idx, h in enumerate(changes,1):
    old=h['old']; new=h['new']
    if s.count(new)==1:
        continue  # already applied
    if s.count(old)!=1:
        sys.exit(f'CONFLICT in patch section {idx}/{len(changes)}: local file is different. Nothing was changed. Share this source file for a safe merge.')
    s=s.replace(old,new,1)
    changed+=1
if changed==0:
    print('PASS: Monthly Audit asset filter is already installed. No changes made.')
    sys.exit(0)
print(f'PASS: {changed} of {len(changes)} patch sections need applying; all matched uniquely.')
if args.check:
    print('Dry run complete; no project files changed. Run --apply to install.')
    sys.exit(0)
backups=project/'_CAFM_PATCH_BACKUPS';backups.mkdir(exist_ok=True)
base=target.name.replace('.swift','')
stamp=datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
backup=backups/f'{base}_before_paul_asset_{stamp}.swift'
shutil.copy2(target,backup)
fd,tmp=tempfile.mkstemp(prefix='.cafm_paul_',suffix='.swift',dir=target.parent)
try:
    with os.fdopen(fd,'wb') as f:
        f.write(s.replace('\n',endings).encode('utf-8'))
    shutil.copymode(target,tmp)
    os.replace(tmp,target)
except Exception:
    try:os.unlink(tmp)
    except OSError:pass
    raise
print('Installed: '+str(target))
print('Backup: '+str(backup))
print('Next: Clean Build Folder in Xcode, then Command-B. Test on TEST server only.')
