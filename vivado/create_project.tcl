# Invoke from repository root: vivado -mode batch -source vivado/run_synth.tcl -tclargs baseline|xpix
set variant [lindex $argv 0]
if {$variant ni {baseline xpix}} {error "expected baseline or xpix"}
set boards [get_board_parts -quiet *zcu102:part0:*]
if {[llength $boards]==0} {error "ZCU102 board file missing; install/verify board files"}
set board [lindex [lsort $boards] end]
set part [get_property PART_NAME $board]
if {[llength [get_parts -quiet $part]]!=1} {error "unsupported ZCU102 part $part"}
puts "VERIFIED_BOARD=$board VERIFIED_PART=$part"
create_project -force $variant build/vivado_$variant -part $part
set_property board_part $board [current_project]
add_files [glob rtl/*.v]
set_property top zcu102_top [current_fileset]
set xp [expr {$variant eq "xpix"}]
set_property generic "XPIX=$xp INIT_FILE=build/${variant}_board.hex" [current_fileset]
add_files -fileset constrs_1 vivado/clock.xdc
update_compile_order -fileset sources_1
