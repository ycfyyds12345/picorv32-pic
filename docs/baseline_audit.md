# Baseline audit
Source archive commit ef203c2b0a3fb793280f5114941416c425c5b461. Original picorv32.v retained byte-for-byte; rtl/ contains an identical copy.

PicoRV32 is a multicycle, in-order RV32 core with a fetch/decode/operand/execute/load/store FSM, shared native instruction/data memory interface, optional dual-port register file and optional barrel shifter. No cache is instantiated.

Module defaults (picorv32.v:62 onward): COUNTERS=1, COUNTERS64=1, REGS_16_31=1, REGS_DUALPORT=1, LATCHED_MEM_RDATA=0, TWO_STAGE_SHIFT=1, BARREL_SHIFTER=0, TWO_CYCLE_COMPARE=0, TWO_CYCLE_ALU=0, COMPRESSED_ISA=0, CATCH_MISALIGN=1, CATCH_ILLINSN=1, PCPI/MUL/FAST_MUL/DIV/IRQ=0. IRQ_QREGS/TIMER=1 only matter with IRQ enabled. TRACE/REGS_INIT_ZERO=0; reset PC=0, IRQ PC=0x10, STACKADDR=0xffffffff.

Decode implements RV32I integer arithmetic, logical, shifts, comparisons, upper immediates, jumps, six branches, byte/halfword/word loads and stores; FENCE is recognized. ECALL/EBREAK trap with IRQ disabled. This is not a privileged CSR implementation. Cycle/time and instruction counter reads are specially decoded (around lines 1079,1629). The RTL count_instr increments at instruction launch/fetch handling (line 1564); reported instret uses that existing implementation, not a new retirement monitor.

Native interface holds valid, address, write data and strobes until ready. wstrb=0 is a read, four byte strobes select little-endian write lanes. Read data must be valid at handshake unless LATCHED_MEM_RDATA is enabled. Lookahead is optional and unused here.

External PCPI receives otherwise unsupported instructions and two register operands. wait prevents the 4-bit illegal-instruction timeout; ready completes, wr enables rd writeback, x0 remains protected by CPU register logic. The internal iterative multiplier decodes funct7=1, asserts registered wait, detects wait rising edge and eventually pulses ready/wr. Divider uses the same start mechanism and iterative quotient calculation; fast multiply has wait=0 and pipelined ready. XPix must promptly assert wait only for its own legal encoding.

PicoSoC simpleuart maps divider at 0x02000004 and data at 0x02000008. TX writes stall while busy; RX read returns 0xffffffff if empty and consumes a buffered byte otherwise. There is one receive byte buffer, no FIFO. Divider comparisons use >, so serial bit duration is divider+2 clocks.

Existing infrastructure: tests/*.S RV32I and M-extension assembly tests with custom print/pass macros; firmware startup/IRQ/hello/sieve/multiply/statistics; native easy testbench plus AXI/Wishbone benches; Makefile defaults to Icarus and rv32imc firmware, not this project's RV32I configuration. scripts contains formal, synthesis, torture and tool-specific flows. XPix uses separate build scripts and preserves upstream firmware/start.S and sections.lds under firmware/; project firmware lives in firmware/xpix/ where names conflict.

Environment: Linux bash; ModelSim SE-64 2020.4, Vivado 2022.2, /tools/ncc-1.0.4-gcc/bin/riscv-gaisler-elf-gcc 10.2.0 with rv32i/ilp32 multilib. Simulator requires local socket access outside the restrictive execution sandbox.
