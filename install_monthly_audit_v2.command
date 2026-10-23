#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
if [ "$#" -ne 1 ] || { [ "$1" != "--check" ] && [ "$1" != "--apply" ]; }; then
  echo "Usage: bash ./install_monthly_audit_v2.command --check | --apply"
  exit 2
fi
python3 ./_monthly_v2_merge/install.py "$1"
