# XPix-RV32 前端开发与前仿最终报告

2026-09-12 完成。项目目录：`/home/ycf/microprocesser_report/picorv32-main`。

**本阶段验收通过：ModelSim 全部测试 `ALL_TESTS_PASS`；Vivado 两版本 `VIVADO_ALL_PASS`。已停止在实物上板之前，没有连接板卡、生成板级 BIT 或填写未经核实的 pin。**

## 交付与原始源码

原 ZIP 已解压。逐文件对比确认压缩包内所有原始文件均未修改，包括原始 `picorv32.v`。`rtl/picorv32.v`、`rtl/simpleuart.v` 是原始文件的逐字节副本，许可证保留。主要新增：

- `rtl/`：XPix PCPI、512 KiB BRAM、SoC、带 UART RX 双触发器同步的 ZCU102 synthetic-clock 顶层。
- `firmware/xpix.h`、`firmware/uart.c/h`、`firmware/image_bench.c`；`firmware/xpix/` 内独立 startup/linker、最小指令程序、三种实现 benchmark、回归程序及 UART 图像服务器。这样没有覆盖原始 firmware/start.S / sections.lds。
- `sim/`：独立随机测试、CPU/BRAM/非法指令/UART/服务器 testbench，CLI `.do`，`run_all.sh`。
- `host/`：PNG/JPG/BMP→raw、raw→PNG、确定性图像、独立 golden model、UART 上传/计算/下载及结果检查工具。
- `vivado/`：器件探测、项目创建、8 ns 约束、综合与布局布线脚本。
- `docs/`：源码审计、ISA、架构、内存图、验证与上板步骤；`reports/`：真实日志、反汇编、性能表、资源/时序、图像输出。

完整新增文件清单见 `file_manifest.txt`，源码完整性见 `source_integrity.md`。

## 自定义 ISA 与握手

R-type CUSTOM-1：opcode=`0x2B`，funct7=`0`，funct3 分别为：

| funct3 | 指令 | 每个 unsigned 8-bit lane |
|---|---|---|
| 000 | PX.ABSDIFF8 | abs(a-b) |
| 001 | PX.THRESH8 | a>=b ? 255 : 0 |
| 010 | PX.ADDUS8 | min(a+b,255)，9-bit sum |
| 011 | PX.MAXU8 | max(a,b) |
| 100 | PX.MINU8 | min(a,b) |

每条同时处理 4 像素，lane0 位于 bits[7:0]。非法 funct3/funct7/opcode 不响应。GNU `.insn` 已实际编译；objdump 检查到全部五种 opcode，Scalar/Packed RV32I 函数没有 custom 指令，Packed 函数确实使用 LW。

PCPI：E0 锁存输入，E1 寄存结果并拉高 ready/wr，E2 CPU 接收。含 E0 在内第二个采样沿看到 ready；从 E0 到 CPU 接收为两整周期。wait 从合法请求出现起生效。CPU 完整指令耗时还包含自身 decode/访存开销。没有把 XPix 插入原 ALU 组合路径。

## ModelSim 结果

| 验证项 | 实际结果 |
|---|---|
| 原始 baseline 内存循环 | PASS，最终计数 40 |
| XPix 独立定向测试与随机测试 | PASS；random_cases=100000；mismatch=0 |
| CPU 最小 custom 程序 | PASS；38 次实际 custom 握手，含 x0 与连续调用 |
| BRAM | PASS；16 写掩码 × 3 地址，含首/末 word 与图像区 |
| CPU 非法编码 | PASS；5 种错误编码在 100 clocks 内 trap |
| UART CPU bit-level | PASS；5 字符字符串，4 字节 RX/BRAM byte write/echo |
| 顶层 UART 图像服务器 | PASS；2 次上传、6 个 kernel、每项 16 像素下载、threshold=128、非法命令 |
| 完整图像 | PASS；两组 256×256，六个 kernel，三种实现 |
| Python 独立 golden | 每组每项每种实现逐字节一致，mismatch=0 |
| 原仓库 RV32I | 37 个原始汇编测试在 baseline / XPix 均通过 |
| 失败退出码 | 故意失败的程序触发 $fatal，CLI 返回 1；正常测试返回 0 |

图像第一组是移动方块 A/B，第二组覆盖所有 65,536 种 byte-pair，包含阈值相等、饱和边界、0/255 极值。六项为 absdiff、threshold、addus、max、min、motion。合计独立检查 2×6×3×65,536 = **2,359,296 个输出字节**，全部 bit-exact。UART 协议测试缩小为 16 像素；没有冒充全帧 bit-level 串口传输测试。

## 性能：256×256 移动方块数据

来自 CPU cycle/instret CSR，非仿真 wall-clock。共同调用/读计数器边界开销保留，比较和输出不计入 kernel。benchmark 阈值默认为 40，可通过 FW_CFLAGS=-DTHRESHOLD=... 重编译；最终数据已去掉不必要的 volatile 阈值重复读取。

| Kernel | Scalar cycles | Packed cycles | XPix cycles | Scalar instret | Packed instret | XPix instret | vs Scalar | vs Packed |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| abs | 3670052 | 2409128 | 753700 | 720903 | 541320 | 131079 | 4.869× | 3.196× |
| thresh | 3145760 | 2029744 | 753700 | 589830 | 456842 | 131079 | 4.174× | 2.693× |
| addus | 3343908 | 2557480 | 753700 | 591367 | 542216 | 131079 | 4.437× | 3.393× |
| max | 3082784 | 2296356 | 753700 | 526854 | 477703 | 131079 | 4.090× | 3.047× |
| min | 3082784 | 2296356 | 753700 | 526854 | 477703 | 131079 | 4.090× | 3.047× |
| motion | 3869216 | 2709812 | 852019 | 723462 | 547083 | 147466 | 4.541× | 3.180× |

全部六项相对 Packed RV32I 都有正加速。原始精度数据见 `performance.csv`；第二组全字节对结果见 `gradient/performance.csv`。所有输出 raw 文件保存在 `motion/` 和 `gradient/`，并提供 `motion/motion_mask.png`、`gradient/saturating_add.png`。

普通非 XPix 程序两种 CPU 均为 **65,070 cycles、12,810 instret**，checksum=9,150,976；包含汇编测试的整套程序均为 **127,509 cycles**，custom_count=0。无额外 cycle regression，详见 `regression.md`。instret 遵循原 PicoRV32 已有 counter 实现，不声称新增了精确退休监控器。

## Vivado 与 125 MHz

本机 board file `xilinx.com:zcu102:part0:3.4` 实际返回 `xczu9eg-ffvb1156-2-e`。Vivado 2022.2 执行 synth_design → opt_design → place_design → phys_opt_design → route_design。

| 配置 | 综合 LUT | 综合 FF | BRAM36 | DSP | 综合 WNS | 布线后 WNS | 布线后 WHS |
|---|---:|---:|---:|---:|---:|---:|---:|
| Baseline | 1650 | 847 | 128 | 0 | +3.983 ns | +2.135 ns | +0.049 ns |
| XPix | 1860 | 973 | 128 | 0 | +3.954 ns | +2.499 ns | +0.044 ns |

增加 210 LUT（12.73%）、126 FF（14.88%），不增加 BRAM/DSP。布线后 LUT/FF 分别为 1609/817 与 1835/969。两个版本均满足 **8.000 ns / 125 MHz**，setup/hold 无违例；无 unconstrained internal endpoints、无 latch loops，OOC DRC 为零违例。没有频率 sweep，因此不报告最大 Fmax。

最终 baseline 最差 setup 为 reset 同步输出→BRAM enable；XPix 为 BRAM 数据→CPU reg_out，未把原 CPU ALU 改造成 XPix 组合路径。两次独立目录实现得到相同资源/时序数据。

这些结果来自 synthetic clock、OOC 布局布线及 0.5 ns I/O 预算，证明当前内部系统在目标频率通过，不等于真实 pin-bound 板级签核。完整报告与 DCP 在 `reports/vivado/`、`build/`。

## 可复现与尚需实物核实事项

`bash sim/run_all.sh` 在不含 build/reports 的 `/tmp/xpix_clean_verify` 完整重建并输出 ALL_TESTS_PASS；`bash vivado/run_all.sh` 在另一个干净目录完整重建并输出 VIVADO_ALL_PASS。所有使用的最终仿真源码已逐字节比对，板固件 INIT 也与综合输入一致。日志见 `clean_run_all.log` / `clean_vivado.log`。这两个 /tmp 目录不是后续运行依赖。

- 实物时钟频率、差分输入、bank 电压、UART 通道、reset 极性及 pin 尚未绑定，按计划留在 bring-up。
- UART 单字节 RX 缓冲，没有 CRC/重传；256-byte ACK 协议已仿真，完整实物 USB-UART 吞吐尚需测试。
- 固件随 BIT 初始化 BRAM，图像经 CPU/UART 动态写入；不依赖仿真图像 preload 上板。
- 当前 server 读回图像；硬件 cycle/instret 的 UART 命令留在下一阶段，现有性能数据均为真实 CPU RTL 仿真测量。
- Vivado 的用户 TclStore 在沙箱不可写，回退安装目录，产生环境级 Common 17-741；未阻止任何实现步骤。原始日志保留。

拿到 ZCU102 的**第一步**是确认 PCB revision 和实际 PL 时钟/串口/引脚来源，再创建经过核实的 board.xdc 与差分时钟包装。随后先 baseline UART banner，再 XPix 图像上传/下载、Python golden 比对。精确命令、协议和排查顺序见 `../docs/board_bringup_plan.md`。

## 验收清单

- [x] 原始 baseline、五条 custom 编码、实际 CPU 执行与 objdump 检查。
- [x] ModelSim 独立单元 ≥100000 random、零 mismatch。
- [x] Scalar / Packed RV32I / XPix 六个 kernel，256×256 motion bit-exact。
- [x] cycle / instret / performance.csv 实测生成，XPix 相对 Packed 全部正加速。
- [x] 原 RV32I 回归与普通程序无额外周期。
- [x] UART、BRAM 字节写和软件图像数据路径验证。
- [x] Vivado 两版本综合、utilization、timing、125 MHz 布线后验证。
- [x] 干净目录复现与完整文档。
- [x] 按要求停在实物 bring-up 前。
