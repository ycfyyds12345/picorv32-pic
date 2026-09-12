module zcu102_top #(parameter XPIX=1,parameter UART_DIV=1083,parameter INIT_FILE="build/firmware.hex")
(input clk,reset,uart_rx,output uart_tx,output [3:0] led);
 wire [31:0] result;wire trap;
 (* ASYNC_REG="TRUE" *) reg [1:0] rst_sync=0;
 (* ASYNC_REG="TRUE" *) reg [1:0] rx_sync=2'b11;
 always @(posedge clk) rx_sync<={rx_sync[0],uart_rx};
 always @(posedge clk) if(reset) rst_sync<=0;else rst_sync<={rst_sync[0],1'b1};
 xpix_soc #(.XPIX(XPIX),.UART_DIV(UART_DIV),.INIT_FILE(INIT_FILE)) soc(clk,rst_sync[1],rx_sync[1],uart_tx,trap,result);
 assign led={trap,result[2:0]};
endmodule
