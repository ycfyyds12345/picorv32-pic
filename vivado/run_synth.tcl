source vivado/create_project.tcl
set_param general.maxThreads 4
file mkdir reports/vivado
# OOC suppresses physical I/O placement until board pin binding is verified.
synth_design -top zcu102_top -part $part -mode out_of_context -flatten_hierarchy rebuilt -generic "XPIX=$xp INIT_FILE=build/${variant}_board.hex"
opt_design
report_utilization -file reports/vivado/${variant}_utilization.rpt
report_timing_summary -file reports/vivado/${variant}_timing.rpt
report_drc -file reports/vivado/${variant}_drc.rpt
write_checkpoint -force build/${variant}_synth.dcp
place_design
phys_opt_design
route_design
report_utilization -file reports/vivado/${variant}_route_utilization.rpt
report_timing_summary -delay_type min_max -max_paths 10 -file reports/vivado/${variant}_route_timing.rpt
report_route_status -file reports/vivado/${variant}_route_status.rpt
write_checkpoint -force build/${variant}_route.dcp
exit
