# Makefile

# defaults
SIM = icarus
TOPLEVEL_LANG = verilog
VERILOG_MODULE ?= ppu_top_p16_e1_w32_f32.v
TEST ?= coco_test_minimal
VERILOG_SOURCES += $(PWD)/../$(VERILOG_MODULE)
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = ppu_top

# MODULE is the basename of the Python test file
MODULE = $(TEST)

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
