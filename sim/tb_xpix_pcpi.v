`timescale 1ns/1ps
module tb_xpix_pcpi;
 reg passed=0;
 reg clk=0, resetn=0, valid=0;
 always #4 clk=~clk;
 reg [31:0] insn=0,a=0,b=0;
 wire wr,wait_o,ready;
 wire [31:0] rd;
 xpix_pcpi dut(clk,resetn,valid,insn,a,b,wr,rd,wait_o,ready);
 integer n,f,j,seed=1234567;
 reg [31:0] ra,rb;
 function [31:0] reference;
 input [31:0] x,y;
 input integer op;
 integer k,xx,yy,z;
 begin
 for(k=0;k<4;k=k+1) begin
 xx=(x>>(8*k))&255; yy=(y>>(8*k))&255;
 case(op)
 0: begin z=xx-yy; if(z<0) z=-z; end
 1: if(xx>=yy) z=255; else z=0;
 2: begin z=xx+yy; if(z>255) z=255; end
 3: if(xx>yy) z=xx; else z=yy;
 4: if(xx<yy) z=xx; else z=yy;
 endcase
 reference[k*8+:8]=z;
 end
 end
 endfunction
 task check;
 input [31:0] x,y;
 input integer op;
 reg [31:0] expected;
 integer clocks;
 begin
 expected=reference(x,y,op);
 @(negedge clk); a=x;b=y;insn=32'h2b|(op<<12);valid=1;
 clocks=0;
 while(!ready && clocks<8) begin @(posedge clk); #1; clocks=clocks+1; end
 if(!ready || !wr || rd!==expected || clocks!=2) $fatal(1,"mismatch op=%0d a=%h b=%h got=%h expected=%h latency=%0d",op,x,y,rd,expected,clocks);
 @(posedge clk); @(negedge clk);valid=0;
 end
 endtask
 initial begin
 repeat(3) @(negedge clk);resetn=1;
 for(f=0;f<5;f=f+1) begin
 check(0,0,f); check(0,32'hffffffff,f); check(32'hffffffff,0,f);
 check(32'h80808080,32'h80808080,f);check(32'hc864ff00,32'h64c800ff,f);
 check(32'hffffffff,32'h01010101,f);check(32'h80808080,32'h7f7f7f7f,f);
 check(32'hffffffff,32'hffffffff,f);check(32'hff81807f,32'h80808080,f);
 end
 for(n=0;n<100000;n=n+1) begin ra=$random(seed);rb=$random(seed); f=($random(seed)&32'h7fffffff)%5;check(ra,rb,f);end
 for(j=0;j<3;j=j+1) begin
 @(negedge clk); valid=1;case(j) 0:insn=32'h33;1:insn=32'h0200002b;2:insn=32'h502b;endcase
 repeat(20) begin @(posedge clk);#1;if(ready||wr||wait_o) $fatal(1,"illegal responded");end
 @(negedge clk);valid=0;
 end
 // Reset while a transaction is in flight.
 @(negedge clk);valid=1;insn=32'h2b;
 @(negedge clk);resetn=0;
 @(negedge clk);if(ready||wr||wait_o) $fatal(1,"reset outputs");valid=0;resetn=1;
 check(32'h12345678,32'h87654321,0);
 $display("XPIX_UNIT_TEST_PASS random_cases=100000 mismatch=0");passed=1;$finish;
 end
 initial begin #10000000;$fatal(1,"timeout");end
endmodule
