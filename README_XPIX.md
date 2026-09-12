# XPix-RV32 前端工程

保留原始 PicoRV32 仓库，新增 RTL、固件、图像工具和验证脚本。硬件是 RV32I + PCPI 4×8-bit SIMD + 512 KiB BRAM + simpleuart，目标 ZCU102。当前不操作实物板卡。

- 全部前仿：`bash sim/run_all.sh`
- 两个版本综合与布局布线：`bash vivado/run_all.sh`
- 全部前端：`bash run_frontend.sh`
- 最终结果：`reports/final_report.md`
- 设计及验收细节：`docs/architecture.md`、`docs/verification_plan.md`
- 下一阶段：`docs/board_bringup_plan.md`

需要 ModelSim、Vivado 2022.2（含 ZCU102 board file）、RV32I GNU 工具链和 Python/Pillow。工具链可通过 RISCV_PREFIX 覆盖；host/requirements.txt 列出 Python 依赖。原 firmware/start.S 与 sections.lds 没有覆盖，新程序使用 firmware/xpix/ 下对应文件。脚本从仓库根目录定位，不依赖当前 shell 的起始目录。
