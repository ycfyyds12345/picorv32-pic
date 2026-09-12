onerror {quit -code 1 -force}
file mkdir build
onbreak {if {[examine -radix unsigned /tb_bram/passed] == 1} {quit -code 0 -force} else {quit -code 1 -force}}
vlib build/bramwork
vmap bramwork build/bramwork
vlog -sv -work bramwork rtl/picorv32.v rtl/xpix_pcpi.v rtl/soc_bram.v rtl/simpleuart.v rtl/xpix_soc.v sim/tb_bram.v
vsim -voptargs=+acc -onfinish stop bramwork.tb_bram
run -all
quit -code 1 -force
