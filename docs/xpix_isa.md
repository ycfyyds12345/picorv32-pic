# XPix ISA v1
CUSTOM-1 R format: `funct7[31:25] | rs2[24:20] | rs1[19:15] | funct3[14:12] | rd[11:7] | 0x2b[6:0]`.
funct7 must be zero. funct3 5..7, nonzero funct7 and other opcodes receive no XPix response.

| Instruction | funct3 | Lane operation (unsigned bytes) | Example rs1,rs2 → rd |
|---|---|---|---|
| PX.ABSDIFF8 | 0 | abs(a-b) | ff0080c8,00ff8064 → ffff0064 |
| PX.THRESH8 | 1 | a>=b ? 255 : 0 | ff81807f,80808080 → ffffff00 |
| PX.ADDUS8 | 2 | min(a+b,255), 9-bit intermediate | ff808000,ff807f00 → ffffff00 |
| PX.MAXU8 | 3 | max(a,b) | ff0080c8,00ff8064 → ffff80c8 |
| PX.MINU8 | 4 | min(a,b) | ff0080c8,00ff8064 → 00008064 |

Lane 0 occupies bits 7:0, lane 3 bits 31:24. Register endian follows little-endian LW/SW; no cross-lane carry. Threshold can differ per lane; replicated T is `T*0x01010101u`.

Protocol: when valid+legal appears in IDLE, wait asserts combinationally to inhibit timeout. Edge E0 latches operands/funct3 and enters EXEC. Edge E1 registers the four lane results and enters DONE; ready/wr become high. Edge E2 CPU accepts result and state returns IDLE. Thus ready is observed after two rising edges including E0 (one full clock E0→E1); request-to-CPU-acceptance is two full clocks E0→E2. CPU instruction cycles include decode/register/memory overhead and must not be equated with this latency. No extra combinational logic enters the original ALU. reset clears state/result; dropping valid aborts pending work. CPU is required to consume the ready handshake and drop valid as PicoRV32 does.

GNU GCC 10.2 assembler accepts `.insn r 0x2b, funct3, 0, rd, rs1, rs2`. firmware/xpix.h supplies all wrappers; reports/xpix_firmware.dump and reports/opcode_check.txt verify actual instruction words. Writes to x0 are discarded by unmodified CPU logic.
