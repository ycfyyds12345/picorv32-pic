#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build reports
FW_CFLAGS=-DBASELINE=1 firmware/build.sh board_server
cp build/board_server.hex build/baseline_board.hex
firmware/build.sh board_server
cp build/board_server.hex build/xpix_board.hex
for variant in baseline xpix; do
 vivado -mode batch -source vivado/run_synth.tcl -log "reports/${variant}_vivado.log" -journal "build/$variant.jou" -tclargs "$variant" > "reports/${variant}_vivado_console.log" 2>&1
done
python3 host/check_ppa.py
echo VIVADO_ALL_PASS
