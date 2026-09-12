#!/usr/bin/env python3
import argparse,csv,re
from pathlib import Path
from golden import apply
p=argparse.ArgumentParser();p.add_argument('dataset');p.add_argument('log');a=p.parse_args()
ops=['abs','thresh','addus','max','min','motion'];rows=[]
log=Path(a.log).read_text()
if 'SOC_TEST_PASS' not in log or 'Fatal:' in log: raise RuntimeError('simulation did not pass')
for op in ops:
    m=re.search(r'(?:# )?'+op+r',((?:\d+,){7}\d+)',log)
    if not m: raise RuntimeError('missing '+op)
    vals=list(map(int,m.group(1).split(',')))
    if vals[-2:]!=[0,0]: raise RuntimeError('CPU mismatch')
    rows.append([op]+vals[:6]+[vals[0]/vals[2],vals[1]/vals[2]])
A=Path(f'build/images/{a.dataset}_a.raw').read_bytes();B=Path(f'build/images/{a.dataset}_b.raw').read_bytes()
out=Path('reports')/a.dataset;out.mkdir(exist_ok=True)
for i,op in enumerate(ops):
    words=[]
    for line in Path(f'build/output_{i}.hex').read_text().splitlines():
        line=line.split('//')[0].strip()
        if not line or line.startswith('@'):continue
        words.extend(int(w,16) for w in line.split())
    raw=b''.join(w.to_bytes(4,'little') for w in words)
    assert len(raw)==3*65536,(op,len(raw))
    golden=apply(op,A,B)
    for j,mode in enumerate(['scalar','packed','xpix']):
        result=raw[j*65536:(j+1)*65536]
        mismatches=sum(x!=y for x,y in zip(result,golden))
        assert mismatches==0,(op,mode,mismatches)
        (out/f'{op}_{mode}.raw').write_bytes(result)
    print(f'{a.dataset} {op}: Python golden + scalar/packed/xpix PASS 65536 pixels mismatch=0')
with (out/'performance.csv').open('w') as f:
    w=csv.writer(f);w.writerow(['workload','scalar_cycles','packed_cycles','xpix_cycles','scalar_instret','packed_instret','xpix_instret','speedup_vs_scalar','speedup_vs_packed']);w.writerows(rows)
assert all(r[-1]>1 for r in rows),'XPix not faster than packed'
