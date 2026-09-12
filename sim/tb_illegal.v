`timescale 1ns/1ps
module tb_illegal;
 reg passed=0;
 reg clk=0,resetn=0;wire tx,trap;wire [31:0] result;
 always #4 clk=~clk;
 xpix_soc #(.INIT_FILE("")) dut(clk,resetn,1'b1,tx,trap,result);
 integer n,c;
 reg [31:0] cases[0:4];
 initial begin
 cases[0]=32'h502b;cases[1]=32'h602b;cases[2]=32'h702b;cases[3]=32'h0200002b;cases[4]=32'hffffffff;
 for(n=0;n<5;n=n+1)begin
 @(negedge clk);resetn=0;dut.ram.mem[0]=cases[n];
 repeat(4) @(negedge clk);resetn=1;c=0;
 while(!trap && c<100) begin @(negedge clk);c=c+1;if(dut.pr)$fatal(1,"illegal custom responded");end
 if(!trap)$fatal(1,"illegal did not trap");
 end
 $display("ILLEGAL_INSTRUCTION_PASS cases=5 bounded_timeout=100");passed=1;$finish;
 end
endmodule
