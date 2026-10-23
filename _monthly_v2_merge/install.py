#!/usr/bin/env python3
"""Three-way merge of the exact reviewed V2 Monthly Audit changes; abort on conflicts."""
import argparse
import datetime
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

FILES = [
    'cafm/Controller/SiteCheck/AddSiteCheckVC.swift',
    'cafm/Controller/SiteCheck/MonthlyAudit/MonthlyAuditQuestionsVC.swift',
    'cafm/Controller/SiteCheck/MonthlyAudit/MonthlyAuditQuestionResponseVC.swift',
]


def normalized(data):
    return data.replace(b'\r\n', b'\n')


def merged_content(local, base, incoming, path):
    if local == incoming:
        return local, 'ALREADY INSTALLED'
    if local == base:
        return incoming, 'EXACT BASELINE'
    with tempfile.TemporaryDirectory(prefix='cafm-v2-merge-') as tmp:
        temp = Path(tmp)
        local_file, base_file, new_file = (temp / n for n in ('local.swift', 'base.swift', 'new.swift'))
        local_file.write_bytes(local)
        base_file.write_bytes(base)
        new_file.write_bytes(incoming)
        p = subprocess.run(['git', 'merge-file', '-p', str(local_file), str(base_file), str(new_file)],
                           stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if p.returncode != 0 or b'<<<<<<<' in p.stdout or b'>>>>>>>' in p.stdout:
            raise RuntimeError(f'CONFLICT in {path}: current Mac code overlaps the V2 patch. No files were changed.\n'
                               f'{p.stderr.decode(errors="replace").strip()}')
        return p.stdout, 'CLEAN THREE-WAY MERGE'


def run(project, apply):
    pkg = Path(__file__).resolve().parent
    manifest = json.loads((pkg / 'manifest.json').read_text())
    if not (project / 'cafm.xcworkspace').is_dir():
        raise RuntimeError('Run this installer from the CAFM workspace folder (contains cafm.xcworkspace).')
    staged = {}
    for rel in FILES:
        target = project / rel
        if not target.is_file():
            raise RuntimeError(f'Missing required Mac source: {rel}; no files were changed.')
        base_data = (pkg / 'reference' / rel).read_bytes()
        new_data = (pkg / 'updated' / rel).read_bytes()
        if hashlib.sha256(base_data).hexdigest() != manifest[rel]['reference_sha256'] or \
           hashlib.sha256(new_data).hexdigest() != manifest[rel]['updated_sha256']:
            raise RuntimeError(f'Package integrity check failed: {rel}')
        original = target.read_bytes()
        result, reason = merged_content(normalized(original), normalized(base_data), normalized(new_data), rel)
        if (rel.endswith('MonthlyAuditQuestionsVC.swift') and
            ('monthly-audit-v2' not in result.decode('utf-8') or '/submission/complete' not in result.decode('utf-8'))):
            raise RuntimeError('V2 API contract verification failed')
        # Preserve CRLF in a locally modified file where required.
        if b'\r\n' in original:
            result = result.replace(b'\n', b'\r\n')
        staged[rel] = (original, result)
        print(f'{"UNCHANGED" if original == result else "READY"}: {rel} ({reason})')
    # No files are modified until EVERY merge and syntax check passes.
    if shutil.which('swiftc'):
        with tempfile.TemporaryDirectory(prefix='cafm-v2-swift-') as tmp:
            for i, (rel, (_, result)) in enumerate(staged.items()):
                f = Path(tmp) / f'{i}.swift'
                f.write_bytes(result)
                p = subprocess.run(['swiftc', '-frontend', '-parse', str(f)], capture_output=True, text=True)
                if p.returncode != 0:
                    raise RuntimeError('Swift syntax check failed in ' + rel + ':\n' + p.stderr)
        print('PASS: Swift syntax checks')
    if not apply:
        print('CHECK PASSED: No project files have been changed. Use --apply when ready.')
        return
    stamp = datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
    backup = project / ('.cafm_monthly_v2_backup_' + stamp)
    touched = [(rel, before, after) for rel, (before, after) in staged.items() if before != after]
    if not touched:
        print('Phase 1 Monthly Audit V2 patch already installed; nothing changed.')
        return
    try:
        for rel, before, _ in touched:
            destination = backup / rel
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(before)
        for rel, _, after in touched:
            target = project / rel
            fd, name = tempfile.mkstemp(prefix=target.name + '.', dir=str(target.parent))
            try:
                with os.fdopen(fd, 'wb') as stream:
                    stream.write(after)
                os.chmod(name, target.stat().st_mode)
                os.replace(name, target)
            finally:
                if os.path.exists(name):
                    os.unlink(name)
    except Exception:
        for rel, before, _ in touched:
            (project / rel).write_bytes(before)
        raise
    print(f'APPLIED: {len(touched)} Swift file(s). Original copies backed up in {backup}')
    print('iOS deployment settings and all other application files were left untouched.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    commands = parser.add_mutually_exclusive_group(required=True)
    commands.add_argument('--check', action='store_true')
    commands.add_argument('--apply', action='store_true')
    args = parser.parse_args()
    try:
        run(Path.cwd(), apply=args.apply)
    except Exception as exc:
        print('ERROR:', exc, file=sys.stderr)
        sys.exit(1)
