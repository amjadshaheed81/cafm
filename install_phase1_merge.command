#!/bin/bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if ! command -v python3 >/dev/null 2>&1; then
  echo "Python 3 is required; install Xcode Command Line Tools." >&2; exit 1
fi
python3 "$HERE/_phase1_merge/install.py" "${1:---apply}"
