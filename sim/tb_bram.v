`timescale 1ns/1ps
module tb_bram;
 reg passed=0;
 reg clk=0,rst=0,valid=0;reg [31:0] addr=0,data=0;reg [3:0] mask=0;
 wire ready;wire [31:0] rd;
 soc_bram #(.INIT_FILE("")) dut(clk,rst,valid,addr,data,mask,ready,rd);
 always #4 clk=~clk;
 reg [31:0] expected,got;integer m,k,n;
 task access;
 input [31:0] a,d;input [3:0] w;
 begin
 @(negedge clk);valid=1;addr=a;data=d;mask=w;
 @(posedge clk);#1;if(!ready) $fatal(1,"BRAM ack missing");got=rd;
 @(posedge clk);@(negedge clk);valid=0;
 end endtask
 initial begin
 repeat(3) @(negedge clk);rst=1;
 for(n=0;n<3;n=n+1) begin
 addr=n==0?0:n==1?32'h10000:32'h7fffc;
 for(m=0;m<16;m=m+1) begin
 access(addr,32'h12345678,15);expected=32'h12345678;
 access(addr,32'habcdef01,m);
 for(k=0;k<4;k=k+1)if((m>>k)&1)expected[k*8+:8]=(32'habcdef01>>(k*8));
 access(addr,0,0);if(got!==expected)$fatal(1,"byte mask mismatch");
 end
 end
 $display("BRAM_TEST_PASS masks=16 addresses=3 endian=little mismatch=0");passed=1;$finish;
 end
 initial begin #100000;$fatal(1,"BRAM timeout");end
endmodule
