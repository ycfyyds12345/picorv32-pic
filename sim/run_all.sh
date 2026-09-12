#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build reports
run_sim() {
 local script=$1 log=$2 marker=$3
 vsim -c -do "sim/$script.do" > "reports/$log.log" 2>&1
 if ! rg -q "$marker" "reports/$log.log"; then tail -30 "reports/$log.log"; return 1; fi
 if rg -q '\*\* Fatal:|\*\* Error:' "reports/$log.log"; then return 1; fi
 echo "$marker"
}
run_sim run_baseline baseline BASELINE_PASS
run_sim run_xpix xpix_unit XPIX_UNIT_TEST_PASS
firmware/build.sh minimal
FIRMWARE=build/minimal.hex run_sim run_soc minimal SOC_TEST_PASS
run_sim run_bram bram BRAM_TEST_PASS
run_sim run_illegal illegal ILLEGAL_INSTRUCTION_PASS
firmware/build.sh uart_test
run_sim run_uart uart UART_BIT_LEVEL_PASS
FW_CFLAGS=-DSERVER_PIXELS=16 firmware/build.sh board_server
cp build/board_server.hex build/server_test.hex
run_sim run_server server UART_SERVER_PASS
python3 host/make_test_image.py
python3 host/image_to_raw.py build/images/gradient.png build/images/roundtrip.raw
cmp build/images/gradient.raw build/images/roundtrip.raw
python3 host/raw_to_image.py build/images/roundtrip.raw build/images/roundtrip.png
firmware/build.sh image_bench
cp reports/image_bench.dump reports/xpix_firmware.dump
python3 host/check_opcode.py
for dataset in motion gradient; do
 FIRMWARE=build/image_bench.hex IMAGES="build/images/$dataset.hex" run_sim run_soc "bench_$dataset" SOC_TEST_PASS
 python3 host/check_bench.py "$dataset" "reports/bench_$dataset.log"
done
cp reports/motion/performance.csv reports/performance.csv
python3 firmware/build_regression.py
cp build/firmware.hex build/regression.hex
for xp in 0 1; do
 name=baseline; if [ "$xp" = 1 ]; then name=xpix; fi
 FIRMWARE=build/regression.hex XPIX=$xp run_sim run_soc "regression_$name" SOC_TEST_PASS
done
python3 host/check_regression.py
FW_CFLAGS=-DBASELINE=1 firmware/build.sh board_server
cp build/board_server.hex build/baseline_board.hex
firmware/build.sh board_server
cp build/board_server.hex build/xpix_board.hex
cmp picorv32.v rtl/picorv32.v
cmp picosoc/simpleuart.v rtl/simpleuart.v
echo ALL_TESTS_PASS
