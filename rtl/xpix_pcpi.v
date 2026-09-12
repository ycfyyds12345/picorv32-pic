`timescale 1ns/1ps
module xpix_pcpi(input clk, resetn, pcpi_valid,
 input [31:0] pcpi_insn, pcpi_rs1, pcpi_rs2,
 output pcpi_wr, output reg [31:0] pcpi_rd,
 output pcpi_wait, pcpi_ready);
 localparam IDLE=0, EXEC=1, DONE=2;
 reg [1:0] state;
 reg [31:0] a,b;
 reg [2:0] op;
 wire legal = pcpi_insn[6:0]==7'h2b && pcpi_insn[31:25]==0 && pcpi_insn[14:12]<=4;
 assign pcpi_wait = resetn && pcpi_valid && (state!=IDLE || legal);
 assign pcpi_ready = resetn && pcpi_valid && state==DONE;
 assign pcpi_wr = pcpi_ready;
 function [7:0] lane;
 input [7:0] x,y;
 input [2:0] f;
 reg [8:0] sum;
 begin
 sum={1'b0,x}+{1'b0,y};
 case(f)
 0: lane=x>=y ? x-y : y-x;
 1: lane=x>=y ? 255 : 0;
 2: lane=sum[8] ? 255 : sum[7:0];
 3: lane=x>=y ? x : y;
 4: lane=x<=y ? x : y;
 default: lane=0;
 endcase
 end
 endfunction
 integer i;
 always @(posedge clk) begin
 if(!resetn) begin state<=IDLE; a<=0; b<=0; op<=0; pcpi_rd<=0; end
 else if(!pcpi_valid) state<=IDLE;
 else case(state)
 IDLE: if(legal) begin a<=pcpi_rs1; b<=pcpi_rs2; op<=pcpi_insn[14:12]; state<=EXEC; end
 EXEC: begin
 for(i=0;i<4;i=i+1) pcpi_rd[8*i+:8]<=lane(a[8*i+:8],b[8*i+:8],op);
 state<=DONE;
 end
 DONE: state<=IDLE;
 default: state<=IDLE;
 endcase
 end
endmodule
