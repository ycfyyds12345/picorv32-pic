onerror {quit -code 1 -force}
file mkdir build
onbreak {if {[examine -radix unsigned /tb_soc/passed] == 1} {quit -code 0 -force} else {quit -code 1 -force}}
vlib build/socwork
vmap socwork build/socwork
vlog -sv -work socwork rtl/picorv32.v rtl/xpix_pcpi.v rtl/soc_bram.v rtl/simpleuart.v rtl/xpix_soc.v sim/tb_soc.v
set xp 1
if {[info exists env(XPIX)]} {set xp $env(XPIX)}
set args {}
if {[info exists env(FIRMWARE)]} {lappend args +firmware=$env(FIRMWARE)}
if {[info exists env(IMAGES)]} {lappend args +images=$env(IMAGES)}
vsim -voptargs=+acc -onfinish stop -gXPIX=$xp socwork.tb_soc {*}$args
run -all
quit -code 0 -force
