ifndef RISCV_PPU_ROOT
$(error must set RISCV_PPU_ROOT to point at the root of RISCV_PPU directory.)
else
PPU_ROOT := $(RISCV_PPU_ROOT)/ppu2
RISCV_PPU_SCRIPTS_DIR := $(PPU_ROOT)/scripts
endif

TOP := tb_ppu
N := 8
ES := 0
WORD := 32
F := 0


DOCS := $(PPU_ROOT)/docs/ppu-docs
NUM_TESTS_PPU := 20



all: run

bender:
	bender sources --flatten --target test > sources.json

morty: bender
	morty -f sources.json -DN=$(N) -DES=$(ES) -DWORD=$(WORD) -DF=$(F) --strip-comments -o a.sv --top $(TOP)

lint: morty
	slang a.sv

sv2v: lint
	# sv2v a.sv -w a.v
	sv2v a.sv --dump-prefix a -w /tmp/a.v && cp amain_1.sv a.v
	make -f Makefile_quartus.mk

icarus: sv2v
	iverilog a.v

run: icarus
	vvp a.out -l a.log
	$(RISCV_PPU_SCRIPTS_DIR)/validate_pipelined.py -n $(N) -es $(ES) -f $(F) -o validate_pipelined.log

clean:
	rm -rf sources.json a*.sv a.v *.out *.log $(DOCS)
	make -C tests clean
	make -C scripts clean

docs: bender
	morty -f sources.json -DN=$(N) -DES=$(ES) -DWORD=$(WORD) -DF=$(F) --doc $(DOCS)
	open $(DOCS)/index.html
	

gen-test-vectors:
	$(RISCV_PPU_SCRIPTS_DIR)/tb_gen.py --num-tests $(NUM_TESTS_PPU) --operation ppu -n $(N) -es $(ES) --shuffle-random
	cp $(PPU_ROOT)/sim/test_vectors/tv_posit_ppu_P$(N)E$(ES).sv $(PPU_ROOT)/sim/test_vectors/tv_posit_ppu.sv


questa: morty
	vlib work && \
	vlog -writetoplevels questa.tops '-timescale' '1ns/1ns' a.sv && \
	vsim -f questa.tops -batch -do "vsim -voptargs=+acc=npr; run -all; exit" -voptargs=+acc=npr