module soc_bram #(parameter WORDS=131072, parameter INIT_FILE="build/firmware.hex")
(input clk,resetn,valid,input [31:0] addr,wdata,input [3:0] wstrb,
 output reg ready,output reg [31:0] rdata);
 (* ram_style="block" *) reg [31:0] mem [0:WORDS-1];
 initial if(INIT_FILE!="") $readmemh(INIT_FILE,mem);
 integer i;
 always @(posedge clk) begin
 ready<=0;
 if(resetn && valid && !ready) begin
 ready<=1;
 rdata<=mem[addr[18:2]];
 for(i=0;i<4;i=i+1) if(wstrb[i]) mem[addr[18:2]][i*8+:8]<=wdata[i*8+:8];
 end
 end
endmodule
