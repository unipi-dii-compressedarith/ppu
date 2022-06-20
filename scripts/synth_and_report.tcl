set prefix $env(WORD)_P$env(N)E$env(ES)

set top_name ppu${prefix}_top.v
puts "Synthesizing: $top_name"

read_verilog $top_name
synth_design -quiet -mode out_of_context -top ppu_top
create_clock -period 20.000 -name clk -waveform {0.000 5.000} [get_ports clk]
report_timing_summary -quiet -file timing_summary_$prefix.txt -no_header
report_power -quiet -file power_summary_$prefix.txt 
report_utilization -quiet -file utilization_summary_$prefix.txt