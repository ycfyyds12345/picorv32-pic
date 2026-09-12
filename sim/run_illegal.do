onerror {quit -code 1 -force}
file mkdir build
onbreak {if {[examine -radix unsigned /tb_illegal/passed] == 1} {quit -code 0 -force} else {quit -code 1 -force}}
vlib build/illegalwork
vmap illegalwork build/illegalwork
vlog -sv -work illegalwork rtl/picorv32.v rtl/xpix_pcpi.v rtl/soc_bram.v rtl/simpleuart.v rtl/xpix_soc.v sim/tb_illegal.v
vsim -voptargs=+acc -onfinish stop illegalwork.tb_illegal
run -all
quit -code 1 -force
