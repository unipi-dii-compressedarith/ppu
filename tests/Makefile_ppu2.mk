# make -f Makefile_new.mk TOP=ppu_top
# cd tests
# make -f Makefile_ppu2.mk

TOPLEVEL_LANG ?= verilog

PWD=$(shell pwd)

ifeq ($(TOPLEVEL_LANG),verilog)
  VERILOG_SOURCES = $(PWD)/../a.v
else
  $(error A valid value (verilog or vhdl) was not provided for TOPLEVEL_LANG=$(TOPLEVEL_LANG))
endif

TOPLEVEL := ppu_top
MODULE   := test_ppu2

include $(shell cocotb-config --makefiles)/Makefile.sim
