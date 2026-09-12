onerror {quit -code 1 -force}
file mkdir build
onbreak {if {[examine -radix unsigned /tb_server/passed] == 1} {quit -code 0 -force} else {quit -code 1 -force}}
vlib build/serverwork
vmap serverwork build/serverwork
vlog -sv -work serverwork rtl/picorv32.v rtl/xpix_pcpi.v rtl/soc_bram.v rtl/simpleuart.v rtl/xpix_soc.v rtl/zcu102_top.v sim/tb_server.v
vsim -voptargs=+acc -onfinish stop serverwork.tb_server
run -all
quit -code 0 -force
