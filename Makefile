export PPU_ROOT=$(git rev-parse --show-toplevel)

RISCV_PPU_SCRIPTS_DIR := $(PPU_ROOT)/scripts

MAKEFILE_NAME := $(lastword $(MAKEFILE_LIST))



TOP ?= ppu_top
N ?= 16
ES ?= 1
WORD ?= 32
F ?= 32
CLK_FREQ ?= 100


##### pipeline ##############
# pipeline for retiming purposes
PIPELINE_DEPTH ?= 0
# pipeline for inner stages separation (see ppu_core_ops). Set to 0 or 1.
INNER_PIPELINE_DEPTH ?= 0
#############################


# FMA-only operation inside the PPU disabled by default (set to 0). Override to 1 to turn on this option.
#FMA_ONLY ?= 0
FMA_OP ?=0
EXACT_DIV ?=1

OUTPUT_NAME := $(TOP)_p$(N)_e$(ES)_w$(WORD)_f$(F)

# Fixed point parameters: Fx<FX_M, FX_B> intended as B total bits, M integer bits, 1 sign bit.
FX_M ?= 31
FX_B ?= 64


DOCS := $(PPU_ROOT)/docs/ppu-docs
NUM_TESTS_PPU := 100

ACTION ?= test


MORTY_ARGS :=                                     \
  -DN=$(N)                                        \
  -DES=$(ES)                                      \
  -DWORD=$(WORD)                                  \
                                                  \
  -DF=$(F)                                        \
                                                  \
  -DFX_M=$(FX_M)                                  \
  -DFX_B=$(FX_B)                                  \
                                                  \
  -DCLK_FREQ=$(CLK_FREQ)                          \
  -DPIPELINE_DEPTH=$(PIPELINE_DEPTH)              \
  -DINNER_PIPELINE_DEPTH=$(INNER_PIPELINE_DEPTH)  \
  -DEXACT_DIV=$(EXACT_DIV)				


top_sv: morty
top_v: sv2v

bender:
	bender sources --flatten --target $(ACTION) > sources.json
	#bender sources --flatten --target rtl > sources.json

morty: bender
	morty -f sources.json $(MORTY_ARGS) -o $(OUTPUT_NAME).sv --top $(TOP) #-DCOCOTB_TEST

morty-ap-top: bender
	morty -f sources.json $(MORTY_ARGS) -o vitis/ppu_ap_top.sv --top ppu_ap_top

morty-vivado:
	morty -f sources.json $(MORTY_ARGS) -o $(OUTPUT_NAME).sv --top ppu
	morty -f sources.json $(MORTY_ARGS) -o $(OUTPUT_NAME).sv --top tb_fma

sv2v: morty
	sv2v $(OUTPUT_NAME).sv -w $(OUTPUT_NAME).v

docs: bender
	morty -f sources.json $(MORTY_ARGS) --top $(TOP) --doc $(DOCS)
	open $(DOCS)/index.html
	

synth:
	cd ./fpga/vivado && vivado ppu.xpr -mode batch -source synth.tcl

########


rtl_schematic:
	scp $(UNIPI_SERVER_USER)@$(UNIPI_SERVER):~/Desktop/ppu/fpga/vivado/schematic.pdf schematic.pdf
		

clean:
	rm -rf sources.json $(OUTPUT_NAME).sv $(OUTPUT_NAME).v *.out *.log $(DOCS) 
	rm -rf work transcript
	#make -C tests clean
	make -f Makefile_vivado.mk clean
	