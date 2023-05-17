# synth_design -mode out_of_context -top ppu_top
synth_design -flatten_hierarchy full -mode out_of_context -retiming -top ppu_top
opt_design
report_utilization -hierarchical -file synthesis_opt_utilization_report.txt

place_design
route_design
report_utilization -hierarchical -file implementation_utilization_report.txt
report_timing_summary -file timing_summary_report.txt
report_power -file power_report.txt
exit
