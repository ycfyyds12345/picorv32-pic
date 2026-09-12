onerror {quit -code 1 -force}
file mkdir build
onbreak {if {[examine -radix unsigned /tb_uart/passed] == 1} {quit -code 0 -force} else {quit -code 1 -force}}
vlib build/uartwork
vmap uartwork build/uartwork
vlog -sv -work uartwork rtl/picorv32.v rtl/xpix_pcpi.v rtl/soc_bram.v rtl/simpleuart.v rtl/xpix_soc.v sim/tb_uart.v
vsim -voptargs=+acc -onfinish stop uartwork.tb_uart
run -all
quit -code 0 -force
