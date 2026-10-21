#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
python3 ./apply_paul_asset_fix.py "$@"
