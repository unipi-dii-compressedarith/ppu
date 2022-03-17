quit -sim
# vcom ppu.v

# compile
vlog ppu.v

vsim -t ns ppu.v
# INPUTS
add wave -divider Inputs: # optional
add wave -color yellow x B A
# OUTPUTS
add wave -divider Outputs: # optional
add wave -color cyan D0 D1 D2 D3
# run
# FORCING VALUES (white space doesn't matter)

# force x    1 , 0 15  ns -r 30  ns
# force B    1 , 0 30  ns -r 60  ns
# force A    1 , 0 60  ns -r 120 ns

view wave


run        1000 ns
