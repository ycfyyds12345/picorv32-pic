# Memory map
512 KiB single-port synchronous inferred BRAM; reset PC 0; stack initialized to 0x80000 and grows downward.

| Inclusive addresses | Purpose |
|---|---|
| 00000000–0000ffff | firmware text/rodata/data/bss, linker limited to 64 KiB |
| 00010000–0001ffff | Frame A (65536 bytes) |
| 00020000–0002ffff | Frame B |
| 00030000–0003ffff | Scalar output |
| 00040000–0004ffff | Packed RV32I output |
| 00050000–0005ffff | XPix output |
| 00060000–0006ffff | scratch / regression data |
| 00070000–0007ffff | stack reserve |
| 02000004 | simpleuart divider, byte-writeable |
| 02000008 | UART data: RX read consumes byte or returns ffffffff; TX write stalls while busy |
| 0200000c | RX status bit 0 = buffered byte available (non-consuming) |
| 02000010 | result / LED status; test firmware writes 1=pass, >1=fail |
| 10000000 | acknowledged diagnostic write sink; simulation prints characters / dumps outputs |

RAM recognizes addresses below 0x80000; word index addr[18:2]; four independent byte strobes. Unaligned byte accesses use CPU lane selection; halfword/word misalignment traps in CPU. RTL test covers all 16 write masks at first word, image base, and last word. Native ready is registered; memory request is served once using valid && !ready, then accepted on the next edge. No array reset loop, allowing BRAM inference.

Board firmware is initialized into BRAM in the FPGA image. Image data is loaded by CPU UART writes, never dependent on `$readmemh` image preload on hardware. Simulation-only tb_soc accepts separate +firmware and +images files, with images occupying A/B exactly. Diagnostic dumps are testbench behavior; no UART bypass is substituted for simpleuart.

UART has a single RX byte buffer, no FIFO, CRC or retransmission. Upload is flow-controlled in 256-byte blocks by ACK; CPU must drain bytes at the configured baud rate. Unmapped addresses do not acknowledge; firmware must remain within this map.
