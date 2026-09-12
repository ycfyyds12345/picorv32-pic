# Failure-path check
A deliberately failing RV32I program wrote result=2 to the result register. `FIRMWARE=build/expected_failure.hex vsim -c -do sim/run_soc.do` invoked `$fatal` and returned exit status 1 as expected. See expected_failure.log. The intentional failure is excluded from the passing test suite and proves that the CLI wrapper does not treat arbitrary simulator termination as PASS.
