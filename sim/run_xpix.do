onerror {quit -code 1 -force}
file mkdir build
onbreak {if {[examine -radix unsigned /tb_xpix_pcpi/passed] == 1} {quit -code 0 -force} else {quit -code 1 -force}}
vlib build/unitwork
vmap unitwork build/unitwork
vlog -sv -work unitwork rtl/xpix_pcpi.v sim/tb_xpix_pcpi.v
vsim -voptargs=+acc -onfinish stop unitwork.tb_xpix_pcpi
run -all
quit -code 0 -force
