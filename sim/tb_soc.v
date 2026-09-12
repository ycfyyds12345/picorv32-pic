`timescale 1ns/1ps
module tb_soc;
 reg passed=0;
 parameter XPIX=1;
 reg [1023:0] firmwarefile;
 initial begin
 if(!$value$plusargs("firmware=%s",firmwarefile)) firmwarefile="build/firmware.hex";
 $readmemh(firmwarefile,dut.ram.mem);
 end
 reg clk=0,resetn=0,rx=1;wire tx,trap;wire [31:0] result;
 always #4 clk=~clk;
 xpix_soc #(.XPIX(XPIX),.INIT_FILE(""),.UART_DIV(14)) dut(clk,resetn,rx,tx,trap,result);
 reg [1023:0] imagefile;
 initial if($value$plusargs("images=%s",imagefile)) begin #1;$readmemh(imagefile,dut.ram.mem,16384,49151);end
 integer cycles=0;integer custom_count=0;
 initial begin repeat(10) @(negedge clk);resetn=1;end
 always @(posedge clk) if(resetn) begin
 cycles<=cycles+1;
 if(dut.pv && dut.pr) custom_count<=custom_count+1;
 if(dut.valid && dut.ready && dut.addr==32'h10000000 && dut.wstrb!=0) begin
 if(dut.wdata[31]) begin
 $writememh($sformatf("build/output_%0d.hex",dut.wdata[7:0]),dut.ram.mem,49152,98303);
 end else $write("%c",dut.wdata[7:0]);
 end
 if(trap) $fatal(1,"CPU trap pc=%h",dut.cpu.reg_pc);
 if(result!=0) begin
 if(result!=1) $fatal(1,"firmware failure code=%d",result);
 $display("SOC_TEST_PASS cycles=%0d custom_count=%0d",cycles,custom_count);passed=1;$finish;
 end
 if(cycles>250000000) $fatal(1,"SOC timeout");
 end
endmodule
