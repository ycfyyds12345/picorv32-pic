# RV32I regression
ModelSim executed 37 unchanged upstream tests on both configurations, all PASS: add, addi, and, andi, auipc, beq, bge, bgeu, blt, bltu, bne, j, jal, jalr, lb, lbu, lh, lhu, lui, lw, or, ori, sb, sh, simple, sll, slli, slt, slti, sra, srai, srl, srli, sub, sw, xor, xori.

| Configuration | Algorithm cycles | instret | checksum | Full regression cycles | Custom instructions |
|---|---:|---:|---:|---:|---:|
| Baseline PCPI=0 | 65070 | 12810 | 9150976 | 127509 | 0 |
| XPix PCPI=1 | 65070 | 12810 | 9150976 | 127509 | 0 |

The exact same RV32I binary was executed. The measured ordinary program performs integer arithmetic, memory writes/reads and data-dependent branches. There is no added algorithm-cycle or full-program-cycle stall. M extension tests are intentionally excluded from RV32I.

The initial handwritten reference checksum was corrected to independently computed 9150976; both CPU configurations match it. See regression_baseline.log, regression_xpix.log and regression_tests.txt. This is instruction regression, not a claim of complete privileged RISC-V compliance.
