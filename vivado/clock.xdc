create_clock -name sys_clk -period 8.000 [get_ports clk]
set_input_delay -clock sys_clk 0.5 [get_ports {reset uart_rx}]
set_output_delay -clock sys_clk 0.5 [get_ports {uart_tx led[*]}]
# Asynchronous external UART input: only first synchronizer stage is exempt.
set_false_path -from [get_ports uart_rx] -to [get_pins {rx_sync_reg[0]/D}]
