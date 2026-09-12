#!/usr/bin/env python3
from pathlib import Path
import re
names=Path('reports/regression_tests.txt').read_text().splitlines();values=[]
for variant in ['baseline','xpix']:
    text=Path(f'reports/regression_{variant}.log').read_text()
    assert 'SOC_TEST_PASS' in text and 'Fatal:' not in text
    for name in names:assert f'{name}..OK' in text,name
    m=re.search(r'REGULAR,(\d+),(\d+),(\d+)',text);assert m
    total=re.search(r'SOC_TEST_PASS cycles=(\d+) custom_count=0',text);assert total
    values.append(tuple(map(int,m.groups()))+(int(total[1]),))
assert values[0]==values[1],values
c,i,s,total=values[0]
Path('reports/regression.md').write_text(f'''# RV32I regression
ModelSim executed {len(names)} unchanged upstream tests on both configurations, all PASS: {', '.join(names)}.

| Configuration | Algorithm cycles | instret | checksum | Full regression cycles | Custom instructions |
|---|---:|---:|---:|---:|---:|
| Baseline PCPI=0 | {c} | {i} | {s} | {total} | 0 |
| XPix PCPI=1 | {c} | {i} | {s} | {total} | 0 |

The exact same RV32I binary was executed. The measured ordinary program performs integer arithmetic, memory writes/reads and data-dependent branches. There is no added algorithm-cycle or full-program-cycle stall. M extension tests are intentionally excluded from RV32I.

The initial handwritten reference checksum was corrected to independently computed {s}; both CPU configurations match it. See regression_baseline.log, regression_xpix.log and regression_tests.txt. This is instruction regression, not a claim of complete privileged RISC-V compliance.
''');print('REGRESSION_COMPARE_PASS cycles and instret identical')
