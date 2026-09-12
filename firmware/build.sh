#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
prefix=${RISCV_PREFIX:-/tools/ncc-1.0.4-gcc/bin/riscv-gaisler-elf-}
name=${1:-minimal}
mkdir -p build reports
read -r -a extra <<< "${FW_CFLAGS:-}"
"${prefix}gcc" "${extra[@]}" -march=rv32i -mabi=ilp32 -O2 -ffreestanding -fno-builtin -fno-strict-aliasing -nostdlib -Ifirmware -Wl,--build-id=none,-T,firmware/xpix/sections.lds -o "build/$name.elf" firmware/xpix/start.S "firmware/xpix/$name.c" -lgcc
"${prefix}objcopy" -O binary "build/$name.elf" "build/$name.bin"
"${prefix}objdump" -d "build/$name.elf" > "reports/$name.dump"
python3 firmware/makehex.py "build/$name.bin" 131072 > "build/$name.hex"
cp "build/$name.hex" build/firmware.hex
