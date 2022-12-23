TOPLEVEL_LANG ?= verilog

PWD=$(shell pwd)

ifeq ($(TOPLEVEL_LANG),verilog)
    VERILOG_SOURCES = $(PWD)/../a.v
else
    $(error A valid value (verilog or vhdl) was not provided for TOPLEVEL_LANG=$(TOPLEVEL_LANG))
endif

TOPLEVEL := core_mul
MODULE   := test_core_mul

include $(shell cocotb-config --makefiles)/Makefile.sim
