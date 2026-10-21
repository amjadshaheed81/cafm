#!/usr/bin/env python3
"""Patch only the optional `question` unwrap inside MonthlyAuditQuestionResponseVC.reloadViews()."""
from __future__ import annotations
import argparse
from datetime import datetime
from pathlib import Path
import os
import shutil
import sys
import tempfile

parser = argparse.ArgumentParser(description='CAFM Monthly Audit optional question compile fix')
g = parser.add_mutually_exclusive_group(required=True)
g.add_argument('--check', action='store_true', help='validate without writing files')
g.add_argument('--apply', action='store_true', help='back up and install the one-line fix')
args = parser.parse_args()
root = Path.cwd()
target = root / 'cafm/Controller/SiteCheck/MonthlyAudit/MonthlyAuditQuestionResponseVC.swift'
if not (root / 'cafm.xcworkspace').exists() or not target.is_file():
    sys.exit('ERROR: Run from the CAFM Xcode project root containing cafm.xcworkspace.')
raw = target.read_bytes()
try:
    source = raw.decode('utf-8')
except UnicodeDecodeError:
    sys.exit('ERROR: Expected a UTF-8 Swift file; no changes made.')
newline = '\r\n' if b'\r\n' in raw else '\n'
normal = source.replace('\r\n', '\n')
old = '    func reloadViews() {\n        guard let response else { return }\n'
new = '    func reloadViews() {\n        guard let response, let question else { return }\n'
uses = 'order: question.order, rule: question.assetCategory'
if normal.count(new) == 1:
    if uses not in normal:
        sys.exit('ERROR: Unrecognised Monthly Audit patch version; no changes made.')
    print('PASS: The optional-question fix is already installed; nothing to change.')
    sys.exit(0)
if normal.count(old) != 1 or normal.count(uses) != 1:
    sys.exit('CONFLICT: The expected reloadViews() or category matcher was not found exactly once. No changes made.')
result = normal.replace(old, new, 1)
assert result.count(new) == 1
print('PASS: Exactly one safe one-line change is required in MonthlyAuditQuestionResponseVC.swift.')
if args.check:
    print('Dry run complete. No files changed. Run --apply to install.')
    sys.exit(0)
backups = root / '_CAFM_PATCH_BACKUPS'
backups.mkdir(exist_ok=True)
stamp = datetime.now().strftime('%Y%m%d-%H%M%S-%f')
backup = backups / f'MonthlyAuditQuestionResponseVC_before_optional_guard_{stamp}.swift'
shutil.copy2(target, backup)
fd, temporary = tempfile.mkstemp(prefix='.cafm_optional_', suffix='.swift', dir=target.parent)
try:
    with os.fdopen(fd, 'wb') as f:
        f.write(result.replace('\n', newline).encode('utf-8'))
    shutil.copymode(target, temporary)
    os.replace(temporary, target)
except BaseException:
    try: os.unlink(temporary)
    except OSError: pass
    raise
print('PATCHED:', target)
print('BACKUP:', backup)
print('Next: Xcode > Product > Clean Build Folder, then Command-B.')
