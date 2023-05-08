ifndef RISCV_PPU_ROOT
$(error must set RISCV_PPU_ROOT to point at the root of RISCV_PPU directory.\
`export RISCV_PPU_ROOT=$$(cd .. && pwd)`)
else
PPU_ROOT := $(RISCV_PPU_ROOT)/ppu
RISCV_PPU_SCRIPTS_DIR := $(PPU_ROOT)/scripts
endif

MAKEFILE_NAME := $(lastword $(MAKEFILE_LIST))


# {iverilog, questa}
SIM ?= iverilog

#TOP := ops #tb_ppu
TOP ?= tb_ppu
N ?= 16
ES ?= 1
WORD ?= 32
F ?= 0
CLK_FREQ ?= 100
PIPE_DEPTH ?= 3

# Fixed point parameters: Fx<FX_M, FX_B> intended as B total bits, M integer bits, 1 sign bit.
FX_M ?= 31
FX_B ?= 64


DOCS := $(PPU_ROOT)/docs/ppu-docs
NUM_TESTS_PPU := 100



all: run

bender:
	bender sources --flatten --target test > sources.json

morty: bender
	morty -f sources.json -DN=$(N) -DES=$(ES) -DWORD=$(WORD) -DF=$(F) -DFX_M=$(FX_M) -DFX_B=$(FX_B) -DCLK_FREQ=$(CLK_FREQ) -DPIPE_DEPTH=$(PIPE_DEPTH) --strip-comments -o a.sv --top $(TOP) #-DCOCOTB_TEST

morty-ap-top: bender
	morty -f sources.json -DN=$(N) -DES=$(ES) -DWORD=$(WORD) -DF=$(F) -DFX_M=$(FX_M) -DFX_B=$(FX_B) -DCLK_FREQ=$(CLK_FREQ) -DPIPE_DEPTH=$(PIPE_DEPTH) --strip-comments -o vitis/ppu_ap_top.sv --top ppu_ap_top


morty-vivado:
	morty -f sources.json -DN=$(N) -DES=$(ES) -DWORD=$(WORD) -DF=$(F) -DFX_M=$(FX_M) -DFX_B=$(FX_B) -DCLK_FREQ=$(CLK_FREQ) -DPIPE_DEPTH=$(PIPE_DEPTH) --strip-comments -o a.sv --top ppu
	morty -f sources.json -DN=$(N) -DES=$(ES) -DWORD=$(WORD) -DF=$(F) -DFX_M=$(FX_M) -DFX_B=$(FX_B) -DCLK_FREQ=$(CLK_FREQ) -DPIPE_DEPTH=$(PIPE_DEPTH) --strip-comments -o a.sv --top tb_fma

lint: morty
	slang a.sv --top $(TOP)

sv2v: lint
	sv2v a.sv -w a.v
# 	sv2v a.sv --dump-prefix a -w /tmp/a.v && cp amain_1.sv a.v
	make -f Makefile_quartus.mk

icarus: sv2v
	iverilog -c .iverilog_cf -s $(TOP) a.v
# 	iverilog -g2012 a.sv


run:
ifeq ($(SIM),iverilog)
	make -f $(MAKEFILE_NAME) run_icarus
else ifeq ($(SIM),questa)
	make -f $(MAKEFILE_NAME) run_questa
else
	@echo "Exiting... Wrong simulator."
endif


run_icarus: icarus
	vvp a.out -l a.log
ifeq ($(TOP),tb_ppu)
	@echo "Validating pipeline"
	$(RISCV_PPU_SCRIPTS_DIR)/validate_pipelined.py -n $(N) -es $(ES) -f $(F) -i ppu_output.log -o validate_pipelined.log
else
	@echo "Not running \`validate pipeline\`"
endif

clean:
	rm -rf sources.json a*.sv a.v *.out *.log $(DOCS)
	make -C tests clean
	make -C scripts clean

docs: bender
	morty -f sources.json -DN=$(N) -DES=$(ES) -DWORD=$(WORD) -DF=$(F) --top $(TOP) --doc $(DOCS)
	open $(DOCS)/index.html
	

gen-test-vectors:
	$(RISCV_PPU_SCRIPTS_DIR)/tb_gen.py --num-tests $(NUM_TESTS_PPU) --operation ppu -n $(N) -es $(ES) --shuffle-random
	cp $(PPU_ROOT)/sim/test_vectors/tv_posit_ppu_P$(N)E$(ES).sv $(PPU_ROOT)/sim/test_vectors/tv_posit_ppu.sv


run_questa: morty
	# vlib work
	# vlog -writetoplevels questa.tops '-timescale' '1ns/1ns' a.sv
	# vsim -f questa.tops -batch -do "vsim -voptargs=+acc=npr; run -all; exit" -voptargs=+acc=npr
	vsim -c -do run.do


########


rtl_schematic:
	scp $(UNIPI_SERVER_USER)@$(UNIPI_SERVER):~/Desktop/ppu/fpga/vivado/schematic.pdf schematic.pdf

synplify:
	scp a.sv $(UNIPI_SERVER_USER)@$(UNIPI_SERVER):~/Desktop/ppu/
		
load_vivado:
	scp a.sv $(UNIPI_SERVER_USER)@$(UNIPI_SERVER):~/Desktop/ppu/

