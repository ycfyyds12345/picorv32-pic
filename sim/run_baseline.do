onerror {quit -code 1 -force}
file mkdir build
vlib build/basework
vmap basework build/basework
vlog -work basework picorv32.v testbench_ez.v
vsim -voptargs=+acc -onfinish stop basework.testbench
run 10 us
set result [examine -radix unsigned {/testbench/memory[255]}]
if {$result < 10} {error "baseline memory loop failed: $result"}
puts "BASELINE_PASS counter=$result"
quit -code 0 -force
