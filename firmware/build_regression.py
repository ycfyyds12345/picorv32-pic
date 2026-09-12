#!/usr/bin/env python3
from pathlib import Path
import subprocess,os
os.chdir(Path(__file__).resolve().parents[1]);prefix=os.environ.get('RISCV_PREFIX','/tools/ncc-1.0.4-gcc/bin/riscv-gaisler-elf-')
flags=['-march=rv32i','-mabi=ilp32','-O2','-ffreestanding','-nostdlib']
exclude={'mul','mulh','mulhsu','mulhu','div','divu','rem','remu'}
names=[p.stem for p in sorted(Path('tests').glob('*.S')) if p.stem not in exclude]
s='.section .text.start\n.global _start\n_start:\n'
for n in names:s+=f'j {n}\n.global {n}_ret\n{n}_ret:\n'
s+='li sp,0x80000\n.option push\n.option norelax\nla gp,__global_pointer$\n.option pop\ncall main\nli t0,0x02000010\nsw a0,0(t0)\n1:j 1b\n'
Path('build/regression_start.S').write_text(s)
objects=[]
for n in names:
    o=f'build/test_{n}.o';objects.append(o)
    subprocess.run([prefix+'gcc',*flags,'-c',f'-DTEST_FUNC_NAME={n}',f'-DTEST_FUNC_TXT="{n}"',f'-DTEST_FUNC_RET={n}_ret',f'tests/{n}.S','-o',o],check=True)
subprocess.run([prefix+'gcc',*flags,'-Wl,--build-id=none,-T,firmware/xpix/sections.lds','build/regression_start.S','firmware/xpix/regression.c',*objects,'-lgcc','-o','build/regression.elf'],check=True)
subprocess.run([prefix+'objcopy','-O','binary','build/regression.elf','build/regression.bin'],check=True)
with open('build/firmware.hex','w') as f:subprocess.run(['python3','firmware/makehex.py','build/regression.bin','131072'],stdout=f,check=True)
Path('reports/regression_tests.txt').write_text('\n'.join(names)+'\n');print('Compiled',len(names),'upstream RV32I tests')
