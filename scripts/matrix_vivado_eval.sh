#!/bin/bash
SCRIPTS_DIR=$RISCV_PPU_DIR/ppu/scripts/
ROOT_DIR=$RISCV_PPU_DIR/ppu
VIVADO_DIR=$RISCV_PPU_DIR/ppu/fpga/vivado
words=(32 64)
ns=(8 16)
ess=(0 1 2)
parts=(xc7s6ftgb196 xc7a12ticsg325 xc7k70tfbv676)


for part in ${parts[@]}; do
	mkdir -p reports/$part
	for word in ${words[@]}; do
		for n in ${ns[@]}; do
			for es in ${ess[@]}; do
				cd $ROOT_DIR
				make ppu WORD=$word N=$n ES=$es F=32
				cd $VIVADO_DIR
				WORD=$word N=$n ES=$es PART=$part vivado -mode batch -nojournal -source $SCRIPTS_DIR/synth_and_report.tcl
				cp *summary* reports/$part
			done
		done
	done
done
