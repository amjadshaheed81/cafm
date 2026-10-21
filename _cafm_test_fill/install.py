#!/usr/bin/env python3
"""CAFM Monthly Audit Test Fill: targeted, backup-first source patch.

Run from /Users/Amjad/Desktop/cafm/cafm. Never replaces an entire file.
"""
import argparse
from datetime import datetime
from pathlib import Path
import json,sys,shutil,tempfile,os,subprocess

parser=argparse.ArgumentParser()
mode=parser.add_mutually_exclusive_group(required=True)
mode.add_argument('--check',action='store_true')
mode.add_argument('--apply',action='store_true')
args=parser.parse_args()
root=Path.cwd()
target=root/'cafm/Controller/SiteCheck/MonthlyAudit/MonthlyAuditQuestionResponseVC.swift'
installer_root=Path(__file__).resolve().parent
if not (root/'cafm.xcworkspace').exists() or not target.is_file():
    sys.exit('ERROR: Run from the CAFM Xcode project root with cafm.xcworkspace.')
patches=json.loads((installer_root/'replacements.json').read_text(encoding='utf8'))
additional=(installer_root/'extension.swift.txt').read_text(encoding='utf8')
original_bytes=target.read_bytes()
try:
    original=original_bytes.decode('utf8')
except UnicodeError:
    sys.exit('ERROR: Existing Swift source must be UTF-8; nothing changed.')
ending='\r\n' if b'\r\n' in original_bytes else '\n'
source=original.replace('\r\n','\n')

# Protect the earlier category-filter and optional-unwrapping compile fixes.
required=('private enum MonthlyAuditMobileCategoryMatcher',
          'order: question.order, rule: question.assetCategory',
          'func reloadViews() {\n        guard let response, let question else { return }')
for item in required:
    if item not in source:
        sys.exit('CONFLICT: A previously required Monthly Audit fix is missing or changed. No files modified. Send the Swift file for merge.')
count=0
for item in patches:
    old,new=item['old'],item['new']
    if source.count(new)==1:
        continue
    if source.count(old)!=1:
        sys.exit('CONFLICT: Unexpected source at '+item['name']+'. No files modified. Send current Swift file for merge.')
    source=source.replace(old,new,1)
    count+=1

marker='// MARK: - TEST-only Monthly Audit draft helper'
if marker not in source:
    if not source.endswith('\n'):
        sys.exit('CONFLICT: Missing newline at end of Swift source.')
    source+='\n'+additional
    count+=1
elif source.count(marker)!=1 or '// END TEST-only Monthly Audit draft helper' not in source:
    sys.exit('CONFLICT: Incomplete previous test-fill patch detected. No files modified.')

# Never silently modify the project if the combined Swift text does not parse.
if shutil.which('swiftc'):
    fd,temp=tempfile.mkstemp(suffix='.swift',prefix='cafm_test_fill_parse_')
    try:
        with os.fdopen(fd,'w',encoding='utf8') as f:f.write(source)
        process=subprocess.run(['swiftc','-frontend','-parse',temp],capture_output=True,text=True,timeout=45)
        if process.returncode!=0:
            sys.exit('ERROR: Swift parse preflight failed; no files modified.\n'+process.stderr[-2500:])
    except subprocess.TimeoutExpired:
        sys.exit('ERROR: Swift syntax preflight timed out; no files modified.')
    finally:
        try:os.unlink(temp)
        except OSError:pass
print(f'PASS: {count} independent patch sections need installing. Existing unrelated source is preserved.')
if count==0:
    print('Already installed; no files changed.')
    sys.exit(0)
if args.check:
    print('Dry run complete. No changes made. Run --apply to install.')
    sys.exit(0)
backup_dir=root/'_CAFM_PATCH_BACKUPS'
backup_dir.mkdir(exist_ok=True)
stamp=datetime.now().strftime('%Y%m%d-%H%M%S-%f')
backup=backup_dir/f'MonthlyAuditQuestionResponseVC_before_test_fill_{stamp}.swift'
shutil.copy2(target,backup)
fd,temp=tempfile.mkstemp(prefix='.cafm_test_fill_',suffix='.swift',dir=target.parent)
try:
    with os.fdopen(fd,'wb') as f:
        f.write(source.replace('\n',ending).encode('utf8'))
    shutil.copymode(target,temp)
    os.replace(temp,target)
except BaseException:
    try:os.unlink(temp)
    except OSError:pass
    raise
print('INSTALLED:',target)
print('BACKUP:',backup)
print('Open cafm.xcworkspace, Clean Build Folder, then Command-B.')
