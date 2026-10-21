#!/usr/bin/env python3
"""Update only 3 CAFM iOS Phase-1 sources, preserving local iOS 17.6 fixes.

Run from project directory via install_live_test_switch.command --check or --apply.
No Podfile, CocoaPods, project.pbxproj, Swift dependency or backend modification.
"""
from __future__ import annotations
import datetime
import hashlib
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BUNDLE = ROOT / '_login_env_installer'
REFERENCE = BUNDLE / 'reference'
SOURCES = [
    'cafm/Helper/Settings/ServerConfiguration.swift',
    'cafm/Helper/Settings/ServerSettingsVC.swift',
    'cafm/Controller/SignUpFlow/LoginVC.swift',
]
CHECK = '--check' in sys.argv or '--dry-run' in sys.argv
APPLY = '--apply' in sys.argv


def fail(message: str):
    print('\nSTOP: ' + message, file=sys.stderr)
    print('No CAFM project files were changed. Do not force an overwrite.', file=sys.stderr)
    raise SystemExit(1)


def norm(data: bytes) -> bytes:
    return data.replace(b'\r\n', b'\n').replace(b'\r', b'\n')


def eol(data: bytes) -> bytes:
    return b'\r\n' if b'\r\n' in data else b'\n'


def adjusted(data: bytes, newline: bytes) -> bytes:
    return norm(data).replace(b'\n', newline)


def make_merge(existing: bytes, baseline: bytes, updated: bytes, name: str):
    current, ancestor, desired = norm(existing), norm(baseline), norm(updated)
    if current == desired:
        return None, 'already installed'
    if current == ancestor:
        return adjusted(updated, eol(existing)), 'matches last Phase 1 baseline'
    with tempfile.TemporaryDirectory(prefix='cafm-env-merge-') as directory:
        parent = Path(directory)
        ours, base, theirs = (parent / 'current', parent / 'baseline', parent / 'update')
        ours.write_bytes(current)
        base.write_bytes(ancestor)
        theirs.write_bytes(desired)
        result = subprocess.run(['git', 'merge-file', '-p', '--diff3',
                                 str(ours), str(base), str(theirs)], capture_output=True)
        if result.returncode != 0 or b'<<<<<<< ' in result.stdout or b'>>>>>>> ' in result.stdout:
            fail('Your Mac has overlapping local edits to ' + name +
                 '. Upload that Swift file for a manual merge. We will preserve your changes.')
        merged = adjusted(result.stdout, eol(existing))
        if norm(merged) == current:
            return None, 'already has changes'
        return merged, 'merged independent local edits'


def preflight():
    if not (ROOT / 'cafm.xcworkspace').is_dir() or not (ROOT / 'cafm.xcodeproj/project.pbxproj').is_file():
        fail('Please extract into the Xcode project folder containing cafm.xcworkspace and cafm.xcodeproj.')
    if not shutil.which('git'):
        fail('Git is needed for safe three-way merging (usually installed with Xcode Command Line Tools).')
    planned, statuses = {}, []
    for name in SOURCES:
        current, baseline, updated = ROOT / name, REFERENCE / name, BUNDLE / 'updated' / name
        if not current.is_file() or not baseline.is_file() or not updated.is_file():
            fail('Missing one of the required project or installer files for ' + name)
        merged, status = make_merge(current.read_bytes(), baseline.read_bytes(), updated.read_bytes(), name)
        if merged is not None:
            planned[current] = merged
        statuses.append((name, status))
    prospective = {name: planned.get(ROOT/name, (ROOT/name).read_bytes()) for name in SOURCES}
    config = prospective[SOURCES[0]].decode('utf-8')
    admin = prospective[SOURCES[1]].decode('utf-8')
    login = prospective[SOURCES[2]].decode('utf-8')
    for snippet in ['var preferredLiveURL: String', 'func saveValidatedURL',
                    'func checkConnection', 'legacyProductionURL', 'testingURL']:
        if snippet not in config: fail('Missing expected server configuration behaviour: ' + snippet)
    for snippet in ['enum CAFMServerSessionSwitch', 'CAFMServerSessionSwitch.switchTo',
                    'confirmSwitch(to: target)', 'ServerConfiguration.shared.preferredLiveURL']:
        if snippet not in admin: fail('Missing expected admin switching behaviour: ' + snippet)
    for snippet in ['installEnvironmentChooser()', 'environmentPickerChanged()',
                    'CAFMServerSessionSwitch.switchTo(target)', 'loginAttemptID']:
        if snippet not in login: fail('Missing expected LIVE / TEST login behaviour: ' + snippet)
    if 'ServerConfiguration.checkConnection(to: target)' in admin:
        fail('A health check still blocks saving the selected server. No files changed.')

    if shutil.which('swiftc'):
        with tempfile.TemporaryDirectory(prefix='cafm-env-parse-') as directory:
            temp = Path(directory)
            swift_files = []
            for number, (name, data) in enumerate(prospective.items()):
                target = temp / (str(number) + '-' + Path(name).name)
                target.write_bytes(data)
                swift_files.append(str(target))
            result = subprocess.run(['swiftc', '-frontend', '-parse', *swift_files],
                                    capture_output=True, text=True)
            if result.returncode != 0:
                fail('Swift syntax validation failed: ' + (result.stderr or result.stdout)[:1100])
    return planned, statuses


def main():
    if not (CHECK or APPLY):
        fail('Select --check first or --apply when ready.')
    planned, statuses = preflight()
    print('CAFM LIVE / TEST login environment update —', 'CHECK ONLY' if CHECK else 'APPLY')
    print('Project:', ROOT)
    for name, status in statuses:
        print(' ', name, '—', status)
    print('Project files to update:', len(planned))
    if CHECK:
        print('PASS: no files changed. Run bash ./install_live_test_switch.command --apply')
        return
    if not planned:
        print('Already installed, no changes needed.')
        return
    timestamp = datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
    backup = ROOT / ('.cafm-live-test-switch-backup-' + timestamp)
    backup.mkdir(exist_ok=False)
    for source in planned:
        path = backup / source.relative_to(ROOT)
        path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, path)
    for target, data in planned.items():
        with tempfile.NamedTemporaryFile(dir=target.parent, prefix='.cafm-switch-', delete=False) as f:
            f.write(data)
            tmp = Path(f.name)
        shutil.copymode(target, tmp)
        os.replace(tmp, target)
    print('PASS: updated', len(planned), 'Swift files; original versions backed up at:', backup)
    print('No deployment targets, Podfile, Xcode project references or CocoaPods changed.')
    print('Now open cafm.xcworkspace, Clean Build Folder, build and test LIVE / TEST on login.')

if __name__ == '__main__':
    main()
