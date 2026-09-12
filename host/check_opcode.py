#!/usr/bin/env python3
import re
from pathlib import Path
text=Path('reports/xpix_firmware.dump').read_text();ops={};func='';packed=0
for line in text.splitlines():
    label=re.match(r'^[0-9a-f]+ <([^>]+)>:',line)
    if label:func=label[1]
    m=re.match(r'\s*[0-9a-f]+:\s+([0-9a-f]{8})\s',line)
    if not m:continue
    word=int(m[1],16)
    if word&127==0x2b:
        assert word>>25==0
        op=(word>>12)&7;assert op<=4;ops[op]=ops.get(op,0)+1
        assert not func.startswith(('scalar_','packed_')),(func,line)
    if func.startswith('packed_') and re.search(r'\blw\b',line):packed+=1
assert set(ops)==set(range(5)),ops
assert packed>=12,packed
report=f'OPCODE_CHECK_PASS opcode=0x2b funct7=0 funct3_counts={ops}\nPacked RV32I LW count={packed}; no custom opcodes in scalar/packed functions\n'
Path('reports/opcode_check.txt').write_text(report);print(report,end='')
