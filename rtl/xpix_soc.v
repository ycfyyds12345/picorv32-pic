module xpix_soc #(parameter XPIX=1, parameter INIT_FILE="build/firmware.hex",parameter UART_DIV=1083)
(input clk,resetn,uart_rx,output uart_tx,output trap,output reg [31:0] result);
 wire valid,instr,ready; wire [31:0] addr,wdata,rdata;wire [3:0] wstrb;
 wire pv,pw,pr,pwait;wire [31:0] pi,pa,pb,pd;
 picorv32 #(.BARREL_SHIFTER(1),.ENABLE_PCPI(XPIX),.STACKADDR(32'h80000)) cpu
 (.clk(clk),.resetn(resetn),.trap(trap),.mem_valid(valid),.mem_instr(instr),.mem_ready(ready),
 .mem_addr(addr),.mem_wdata(wdata),.mem_wstrb(wstrb),.mem_rdata(rdata),
 .pcpi_valid(pv),.pcpi_insn(pi),.pcpi_rs1(pa),.pcpi_rs2(pb),.pcpi_wr(pw),.pcpi_rd(pd),.pcpi_wait(pwait),.pcpi_ready(pr),.irq(32'b0),.eoi(),.trace_valid(),.trace_data(),.mem_la_read(),.mem_la_write(),.mem_la_addr(),.mem_la_wdata(),.mem_la_wstrb());
 generate if(XPIX) begin
 xpix_pcpi xp(clk,resetn,pv,pi,pa,pb,pw,pd,pwait,pr);
 end else begin assign pw=0;assign pd=0;assign pwait=0;assign pr=0;end endgenerate
 wire ram_sel=valid && addr<32'h80000;
 wire ram_ready; wire [31:0] ram_data;
 soc_bram #(.INIT_FILE(INIT_FILE)) ram(clk,resetn,ram_sel,addr,wdata,wstrb,ram_ready,ram_data);
 wire div_sel=valid && addr==32'h02000004;
 wire dat_sel=valid && addr==32'h02000008;
 wire status_sel=valid && addr==32'h0200000c;
 wire result_sel=valid && addr==32'h02000010;
 wire print_sel=valid && addr==32'h10000000;
 wire [31:0] div_data,dat_data;wire dat_wait;
 simpleuart #(.DEFAULT_DIV(UART_DIV)) uart(.clk(clk),.resetn(resetn),.ser_tx(uart_tx),.ser_rx(uart_rx),
 .reg_div_we(div_sel?wstrb:4'b0),.reg_div_di(wdata),.reg_div_do(div_data),
 .reg_dat_we(dat_sel && wstrb[0]),.reg_dat_re(dat_sel && wstrb==0),.reg_dat_di(wdata),.reg_dat_do(dat_data),.reg_dat_wait(dat_wait));
 assign ready=ram_ready || div_sel || (dat_sel && !dat_wait) || status_sel || result_sel || print_sel;
 assign rdata=ram_ready?ram_data:div_sel?div_data:dat_sel?dat_data:status_sel?{31'b0,dat_data!=32'hffffffff}:result;
 always @(posedge clk) begin
 if(!resetn) result<=0;
 else if(result_sel && wstrb==15) result<=wdata;
 end
endmodule
