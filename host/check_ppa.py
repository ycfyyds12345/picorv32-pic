#!/usr/bin/env python3
from pathlib import Path
import re
rows=[]
for v in ['baseline','xpix']:
    u=Path(f'reports/vivado/{v}_utilization.rpt').read_text()
    ru=Path(f'reports/vivado/{v}_route_utilization.rpt').read_text()
    t=Path(f'reports/vivado/{v}_route_timing.rpt').read_text()
    st=Path(f'reports/vivado/{v}_timing.rpt').read_text()
    def val(label,txt=u):
        m=re.search(r'\| '+re.escape(label)+r'\s*\|\s*(\d+)',txt);assert m,label;return int(m[1])
    def timing(txt):
        m=re.search(r'WNS\(ns\).*?\n.*?\n\s*([\d.-]+)\s+([\d.-]+)\s+(\d+)\s+\d+\s+([\d.-]+)',txt,re.S);assert m
        return float(m[1]),float(m[4]),int(m[3])
    wns,whs,fail=timing(t);sw,_,_=timing(st)
    assert wns>=0 and whs>=0 and fail==0,(v,wns,whs)
    assert 'All user specified timing constraints are met.' in t
    assert val('Block RAM Tile')==128 and val('DSPs')==0
    rows.append([v,val('CLB LUTs*'),val('CLB Registers'),val('Block RAM Tile'),val('DSPs'),sw,wns,whs,val('CLB LUTs',ru),val('CLB Registers',ru)])
s='''# PPA summary — actual Vivado 2022.2 reports
ZCU102 board file xilinx.com:zcu102:part0:3.4 verified PART_NAME=xczu9eg-ffvb1156-2-e. Common 8.000 ns (125 MHz) synthetic clock; both builds contain the same 512 KiB BRAM/UART subsystem and RX synchronizer. Firmware INIT contents differ appropriately for baseline vs custom server; no memory capacity differences.

| Build | Synth LUT | Synth FF | BRAM36 tiles | DSP | Synth WNS ns | Route WNS ns | Route WHS ns | Route LUT | Route FF |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
'''
for r in rows:s+='| '+' | '.join(map(str,r))+' |\n'
b,x=rows
s+=f'''\nXPix synthesis increment: {x[1]-b[1]} LUT ({100*(x[1]-b[1])/b[1]:.2f}%), {x[2]-b[2]} FF ({100*(x[2]-b[2])/b[2]:.2f}%), zero additional BRAM or DSP. This measures PCPI plus arithmetic together; no dummy-PCPI split is claimed.

Both versions pass 125 MHz after synth_design, opt_design, place_design, phys_opt_design and route_design. Reported post-route WNS/hold margins are measured, not an Fmax estimate. No frequency sweep was performed. OOC mode excludes board I/O buffers and real pin placement; this proves the constrained internal subsystem target, not a completed board timing sign-off. Only the asynchronous UART input to its first RX synchronizer D pin is false-pathed. Real clock/reset/pin constraints must be verified at bring-up.

See *_timing.rpt (post-synthesis estimate), *_route_timing.rpt (actual route), *_route_status.rpt, *_drc.rpt and *.dcp under build/. Final longest setup paths are baseline reset synchronizer→BRAM enable and XPix BRAM data→CPU reg_out; XPix is not inserted into the original CPU ALU. Original picorv32.v is unchanged.
'''
Path('reports/ppa_summary.md').write_text(s);print('PPA_CHECK_PASS 125MHz setup/hold clean for both builds')
