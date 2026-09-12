# Clean-directory reproduction

All final simulation inputs (RTL, sim scripts, project C/assembly/linker sources, firmware builder, Python golden/check scripts) were compared byte-for-byte with the copies used in /tmp/xpix_clean_verify. build/ and reports/ were absent before the run. `bash sim/run_all.sh` rebuilt firmware, generated input images, invoked actual vlog/vsim for every test and ended with ALL_TESTS_PASS. Final logs, ELF/bin/hex/disassembly, CSV and raw image outputs were copied back into this repository. See clean_run_all.log.

A second clean directory /tmp/xpix_synth_verify started without build/reports and ran `bash vivado/run_all.sh`, ending with PPA_CHECK_PASS and VIVADO_ALL_PASS. Final LUT/FF/BRAM/DSP and setup/hold values reproduced exactly. Both board firmware INIT images were byte-compared with the archived final images. See clean_vivado.log and the primary reports/vivado/ reports.

Original archive integrity was also checked file-by-file; all original files remain unchanged. This project does not depend on either /tmp directory to rerun. Shell syntax and Python compilation checks passed. The separately intentional expected_failure.log confirms the simulator's nonzero exit path; it is not a failure of the passing suite.
