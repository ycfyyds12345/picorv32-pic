`timescale 1ns/1ps
module tb_uart;
 reg passed=0;
 reg [1023:0] firmwarefile;
 initial begin
 if(!$value$plusargs("firmware=%s",firmwarefile)) firmwarefile="build/firmware.hex";
 $readmemh(firmwarefile,dut.ram.mem);
 end
 reg clk=0,resetn=0,rx=1;wire tx,trap;wire [31:0] result;
 always #4 clk=~clk;
 xpix_soc #(.INIT_FILE(""),.UART_DIV(14)) dut(clk,resetn,rx,tx,trap,result);
 reg [7:0] expected[0:8];integer got=0;integer j;reg [7:0] byte_rx;
 initial begin expected[0]="X";expected[1]="P";expected[2]="i";expected[3]="x";expected[4]=10;expected[5]=0;expected[6]=127;expected[7]=128;expected[8]=255;end
 initial forever begin
 @(negedge tx);repeat(24) @(posedge clk);
 for(j=0;j<8;j=j+1) begin byte_rx[j]=tx;repeat(16) @(posedge clk);end
 if(tx!==1) $fatal(1,"TX stop bit");
 if(got>=9 || byte_rx!==expected[got]) $fatal(1,"UART mismatch index=%d got=%h",got,byte_rx);
 got=got+1;
 end
 task send;
 input [7:0] b;integer k;
 begin
 @(negedge clk);rx=0;repeat(16) @(negedge clk);
 for(k=0;k<8;k=k+1) begin rx=b[k];repeat(16) @(negedge clk);end
 rx=1;repeat(16) @(negedge clk);
 end endtask
 initial begin
 repeat(10) @(negedge clk);resetn=1;
 wait(got==5);repeat(32) @(negedge clk);
 send(0);wait(got==6);send(127);wait(got==7);send(128);wait(got==8);send(255);wait(got==9);
 wait(result!=0);if(result!=1||trap) $fatal(1,"UART firmware failed");
 $display("UART_BIT_LEVEL_PASS tx_string=5 rx_echo=4 byte_write=PASS");passed=1;$finish;
 end
 always @(posedge clk) if(resetn&&trap) $fatal(1,"trap");
 initial begin #1000000;$fatal(1,"UART timeout");end
endmodule
