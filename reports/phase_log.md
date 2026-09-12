# Executed phase record

- Phase 0: archive extracted; original source and PCPI/native-memory/UART/Makefile audited; real tool versions and GCC RV32I multilib confirmed.
- Phase 1: original testbench_ez compiled with vlog and executed with vsim; memory loop final value 40 checked.
- Phases 2–3: registered XPix RTL implemented; all directed and 100000 seeded random transactions pass. Non-XPix decode/reset checks pass.
- Phases 4–6: GNU .insn assembled and objdump inspected; CPU completes 38 minimal custom transactions including rd=x0; 512 KiB BRAM and native UART map integrated; all BRAM masks and CPU illegal decode tests pass.
- Phases 7–8: 18 scalar/packed/custom kernels compiled and run on CPU, six operations on each of two 256×256 datasets, independently checked against Python. Threshold volatile qualifier removed before final measurement to avoid unequal redundant memory accesses. Only final measurements are authoritative.
- Phase 9: real simpleuart bit-level CPU string/RX/echo pass; server protocol upload/compute/download and threshold override tested on top-level with RX synchronizer, six kernels ×16 pixels. Full frames use separate CPU image simulation.
- Phase 10: 37 unmodified upstream RV32I assembly tests on both CPU configurations pass; ordinary program cycles/instret/checksum and total regression cycles match exactly.
- Phase 11: actual Vivado board-part discovery, both synth/opt/place/phys_opt/route flows completed; final 125 MHz timing and resources in ppa_summary.md. RX synchronizer included. Independent clean-directory synthesis rerun validates scripts.
- Phase 12: clean-directory ModelSim rerun, independent output checking, original-file integrity check and final report. No board connection/programming/bitstream/pin binding performed.

Resolved engineering issues: sandbox blocked ModelSim local socket (simulation authorized outside sandbox); Tcl array visibility needed explicit access; shared firmware.hex was replaced by named per-program images; baseline checksum literal corrected using independent Python result; .do success/failure status made explicit, and a deliberately failing firmware confirmed nonzero exit; Vivado -log/-journal placed before -tclargs; route utilization parser accepts Vivado's label without synthesis asterisk.

Environment warning: Vivado cannot write the user's Tcl plugin store inside the restricted sandbox and falls back to its installation Tcl store (Common 17-741). Both flows still complete; no synthesis/design critical warning is hidden by this note. Actual DRC reports have zero violations for the current OOC design. This does not replace board-level pin/clock DRC.
