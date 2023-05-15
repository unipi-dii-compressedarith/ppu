#synth_design -mode out_of_context -top ppu_top [-part xc7z020clg484-1] -retiming -flatten_hierarchy full

synth_design -flatten_hierarchy full -mode out_of_context -retiming \
  -top ppu_top

opt_design
report_utilization -hierarchical -file synthesis_opt_utilization.txt

place_design

report_utilization -hierarchical -file implementation_utilization.txt
report_timing_summary -file timing_summary.txt

exit
