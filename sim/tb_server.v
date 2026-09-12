`timescale 1ns/1ps
module tb_server;
 reg passed=0;
 reg clk=0,resetn=0,rx=1;wire tx,trap;wire [31:0] result;
 always #4 clk=~clk;
 wire [3:0] led;
 assign trap=led[3];
 zcu102_top #(.INIT_FILE("build/server_test.hex"),.UART_DIV(14)) dut(clk,!resetn,rx,tx,led);
 reg [7:0] received[0:1023];reg [7:0] byte_rx;integer got=0,j,used=0;
 reg [7:0] a[0:15],b[0:15];integer i,op,z;
 initial forever begin
 @(negedge tx);repeat(24) @(posedge clk);
 for(j=0;j<8;j=j+1)begin byte_rx[j]=tx;repeat(16) @(posedge clk);end
 if(tx!==1)$fatal(1,"server stop bit");received[got]=byte_rx;got=got+1;
 end
 task send;input [7:0] v;integer k;
 begin @(negedge clk);rx=0;repeat(16) @(negedge clk);
 for(k=0;k<8;k=k+1)begin rx=v[k];repeat(16) @(negedge clk);end
 rx=1;repeat(16) @(negedge clk);end endtask
 task expect_byte;input [7:0] v;
 begin wait(got>used);if(received[used]!==v)$fatal(1,"server byte %d got=%h expected=%h",used,received[used],v);used=used+1;end endtask
 initial begin
 for(i=0;i<16;i=i+1)begin a[i]=i*17;b[i]=255-i*17;end
 repeat(10) @(negedge clk);resetn=1;
 expect_byte("X");expect_byte("P");expect_byte("I");expect_byte("X");expect_byte("1");expect_byte(10);
 send(1);expect_byte("R");for(i=0;i<16;i=i+1)send(a[i]);expect_byte("K");
 send(2);expect_byte("R");for(i=0;i<16;i=i+1)send(b[i]);expect_byte("K");
 send(8'h30);send(128);expect_byte("K");
 for(op=0;op<6;op=op+1)begin
 send(8'h10+op);expect_byte("K");send(8'h20);
 for(i=0;i<16;i=i+1)begin
 case(op)
 0:begin z=a[i]-b[i];if(z<0)z=-z;end
 1:z=a[i]>=b[i]?255:0;
 2:begin z=a[i]+b[i];if(z>255)z=255;end
 3:z=a[i]>b[i]?a[i]:b[i];
 4:z=a[i]<b[i]?a[i]:b[i];
 5:begin z=a[i]-b[i];if(z<0)z=-z;z=z>=128?255:0;end
 endcase
 expect_byte(z);
 end
 end
 send(8'hff);expect_byte("E");
 $display("UART_SERVER_PASS uploads=2 kernels=6 pixels_per_kernel=16 threshold=128 invalid_command=PASS");passed=1;$finish;
 end
 always @(posedge clk)if(resetn&&trap)$fatal(1,"server trap");
 initial begin #2000000;$fatal(1,"server timeout");end
endmodule
