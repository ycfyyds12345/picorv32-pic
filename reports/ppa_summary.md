# PPA summary — actual Vivado 2022.2 reports
ZCU102 board file xilinx.com:zcu102:part0:3.4 verified PART_NAME=xczu9eg-ffvb1156-2-e. Common 8.000 ns (125 MHz) synthetic clock; both builds contain the same 512 KiB BRAM/UART subsystem and RX synchronizer. Firmware INIT contents differ appropriately for baseline vs custom server; no memory capacity differences.

| Build | Synth LUT | Synth FF | BRAM36 tiles | DSP | Synth WNS ns | Route WNS ns | Route WHS ns | Route LUT | Route FF |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| baseline | 1650 | 847 | 128 | 0 | 3.983 | 2.135 | 0.049 | 1609 | 817 |
| xpix | 1860 | 973 | 128 | 0 | 3.954 | 2.499 | 0.044 | 1835 | 969 |

XPix synthesis increment: 210 LUT (12.73%), 126 FF (14.88%), zero additional BRAM or DSP. This measures PCPI plus arithmetic together; no dummy-PCPI split is claimed.

Both versions pass 125 MHz after synth_design, opt_design, place_design, phys_opt_design and route_design. Reported post-route WNS/hold margins are measured, not an Fmax estimate. No frequency sweep was performed. OOC mode excludes board I/O buffers and real pin placement; this proves the constrained internal subsystem target, not a completed board timing sign-off. Only the asynchronous UART input to its first RX synchronizer D pin is false-pathed. Real clock/reset/pin constraints must be verified at bring-up.

See *_timing.rpt (post-synthesis estimate), *_route_timing.rpt (actual route), *_route_status.rpt, *_drc.rpt and *.dcp under build/. Final longest setup paths are baseline reset synchronizer→BRAM enable and XPix BRAM data→CPU reg_out; XPix is not inserted into the original CPU ALU. Original picorv32.v is unchanged.
