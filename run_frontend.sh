#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
bash sim/run_all.sh
bash vivado/run_all.sh
echo FRONTEND_ALL_PASS
