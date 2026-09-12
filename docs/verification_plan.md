# Verification and reproduction
From repository root run `bash sim/run_all.sh`. It builds all firmware and image inputs, runs actual vlog/vsim, checks explicit pass markers and nonzero failure exit codes, validates outputs with independent Python, and prints ALL_TESTS_PASS only after all gates pass. Required tools: ModelSim vsim/vlog/vlib/vmap, Python3 with Pillow, RISC-V GCC/objcopy/objdump. Default RISCV_PREFIX is /tools/ncc-1.0.4-gcc/bin/riscv-gaisler-elf-; override for another RV32I-capable GNU toolchain. Builds use -march=rv32i -mabi=ilp32, not the upstream rv32imc defaults.

Stages:
1. Unchanged upstream native easy baseline memory-loop test with checked final memory value.
2. XPix unit: directed extremes for all five instructions, exactly 100000 seeded random words/ops, illegal decode rejection, reset during transaction and recovery, fixed registered latency assertion.
3. CPU minimal: actual five .insn encodings, continuous operations, x0 destination protection, 38 completed custom operations.
4. BRAM: 16 byte masks × 3 boundary/region addresses; illegal CPU instructions: reserved funct3=5/6/7, funct7!=0, foreign opcode must trap within 100 clocks.
5. UART: real bit-level string and RX/echo through CPU byte writes. Image-server protocol on zcu102_top includes RX synchronizer, two uploads, six commands, result downloads, threshold=128 and illegal command. Protocol simulation uses SERVER_PIXELS=16 for speed; production default is 65536. Full-size algorithm tests remain 256×256.
6. Host grayscale image conversion round trip; deterministic motion and exhaustive byte-pair images.
7. CPU image/cycle tests: 6 kernels × 2 datasets × 3 implementations × 65536 pixels, scalar/packed/XPix compare in firmware plus independent Python golden checks on actual memory dumps. Each dataset writes its own performance CSV and raw output artifacts.
8. Upstream 37 RV32I tests on each CPU, same binary ordinary loop cycle/instret/checksum equality.
9. objdump verifies all five opcode=0x2b funct3 values and absence in scalar/packed functions; packed functions contain word loads.
10. Original source copies compare byte-for-byte.

`bash vivado/run_all.sh` rebuilds both server firmware images, discovers board part, synthesizes and routes both configurations, and checks 125 MHz setup/hold and resource reports. No board or hardware manager is used. `bash run_frontend.sh` runs both phases.

Single tests: `vsim -c -do sim/run_xpix.do` or `FIRMWARE=build/minimal.hex vsim -c -do sim/run_soc.do`; create build and compile desired firmware first using firmware/build.sh. Testbenches have bounded timeouts and fail on mismatch. Scripts observe explicit passed registers; a simulator $fatal must not be mistaken for successful $finish. ModelSim requires local socket permission in restricted agent sandboxes.

Cycle/instret measurements use CPU counters; elapsed host time is not performance data. Warm-cache effects do not apply because there is no cache. Fixed counter/call overhead is retained equally rather than subtracted speculatively. Threshold in benchmark is compiler-visible and identical for all three algorithms (default 40; FW_CFLAGS=-DTHRESHOLD=128 changes it). Board server supports runtime threshold updates.
