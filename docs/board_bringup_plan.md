# ZCU102 下一阶段 bring-up（本阶段未连接或操作板卡）

1. 先确认手中板卡 PCB revision、器件丝印、启动模式及对应官方原理图/UG1182。现有 Vivado 3.4 board file 给出 xczu9eg-ffvb1156-2-e；不得把开发机 board file 当作实物 revision 的证据。
2. 核实实际 PL 差分时钟来源及频率。125 MHz 是当前内部目标；SI570 是可编程时钟，不能假定出厂状态就是 125 MHz。若实际输入不同，使用 Clocking Wizard/MMCM 生成 125 MHz 并等待 locked 后释放 reset。
3. 依据该 revision 原理图及 Vivado board pin map 确认时钟 P/N、PL UART 的 CP2108 通道与信号方向、reset 极性、LED 位及 bank 电压。新增经复核的 board.xdc（PACKAGE_PIN、IOSTANDARD、差分时钟及 generated clock）。本项目没有填写猜测 pin。
4. 将当前 synthetic clk 顶层外包一层真实 IBUFDS / 必要的 MMCM；保留 RX 两级同步器；复核按钮消抖/复位同步和 MMCM lock 复位条件。检查 report_cdc、report_drc 和 report_timing_summary；本阶段 OOC 结果不替代 pin-bound implementation。
5. 先构建 baseline：FW_CFLAGS=-DBASELINE=1 firmware/build.sh board_server，保存 hex。再构建 XPix：firmware/build.sh board_server。每个 bit 必须对应其自己的 firmware INIT。使用正式 I/O 综合/布局布线，通过 DRC 后才生成 bitstream。不要在 OOC 设计上直接视作可上板 bit。
6. 上电后检查供电/时钟与 JTAG chain，确认硬件 part；先下载 baseline BIT。打开确认的 PL UART 串口（115200、8N1、无流控），按 reset，检查 `XPIX1\n` banner。当前 125 MHz 对应 DEFAULT_DIV=1083，实际 baud=125000000/(1083+2)≈115207.37。若改系统时钟必须重算 divider。
7. 下载 XPix BIT，重复 banner 检查。LED[3] 为 trap，低 3 位为 result 状态；服务器持续运行，不会自动写测试成功码。
8. 生成数据：`python3 host/make_test_image.py`。执行 `python3 host/uart_host.py /dev/ttyUSBn build/images/moving_square_a.raw build/images/moving_square_b.raw build/board_motion.raw --op motion --threshold 40`（串口名替换为实际 PL UART 通道）。要求 pixels=65536 mismatch=0。
9. `python3 host/raw_to_image.py build/board_motion.raw build/board_motion.png`。依次运行 --op abs/thresh/addus/max/min，输入 gradient/raw 或两个运动帧；每次均比较 Python golden。对 baseline 固件重复相同输入做硬件功能对照。
10. 如 UART 超时，先检查 PL 通道、时钟/divider、TX/RX 方向、reset 和 trap LED；再增加 ILA 观察 native bus 与 PCPI valid/wait/ready。不要通过放松随机 pin 或禁用 DRC 来生成 BIT。
11. 实物验证后单独增加 UART 性能读回命令，将 cycle/instret 与仿真记录对照。当前 server 协议返回图像，前仿 benchmark 的计数通过 simulation diagnostic sink 导出，尚未声称实物测量结果。

协议：命令 01/02 上传 A/B，设备先 R，然后每 256 字节 K（最后不足 256 也 K）；10..15 分别执行 abs/thresh/addus/max/min/motion，完成 K；20 返回 65536 字节结果；30 后跟阈值字节，设备 K；其他命令 E。像素顺序是 row-major uint8，PC 不发送压缩图像。单 RX 缓冲、无 CRC/重传；拿到板卡后验证完整帧 UART 吞吐和 USB 串口分包行为。
