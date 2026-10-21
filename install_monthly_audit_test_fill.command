#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
python3 "_cafm_test_fill/install.py" "$@"
