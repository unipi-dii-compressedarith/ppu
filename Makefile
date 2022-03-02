all: \
	gen-test-vectors \
	ppu-core_ops8 \
	ppu-core_ops16 \
	ppu-core_ops32 \
	div-against-pacogen8 \
	div-against-pacogen16 \
	div-against-pacogen32 \
	verilog-quartus16 \
	lint 

.PHONY : all

SRC_FOLDER := ../src
SRC_PACOGEN := ../../PaCoGen


ifeq ($(ES),0)
ES_FIELD_PRESENCE_FLAG := -DNO_ES_FIELD
endif

ifeq ($(F),-1)
else
FLOAT_TO_POSIT_FLAG := -DFLOAT_TO_POSIT -DF=$(F)
SRC_CONVERSIONS_PPU := \
	$(SRC_FOLDER)/conversions/defines.vh \
	$(SRC_FOLDER)/conversions/float_decoder.sv

endif


NR_STAGES := $(ES) 	# actually it's 0 for N in (0..=8), 1 for N in (9..=16), 2 for N in (17..=32)

NUM_TESTS_PPU := 500

SRC_PPU_CORE_OPS := \
	$(SRC_FOLDER)/utils.sv \
	$(SRC_FOLDER)/constants.vh \
	$(SRC_FOLDER)/common.sv \
	$(SRC_FOLDER)/ppu_core_ops.sv \
	$(SRC_FOLDER)/posit_to_pif.sv \
	$(SRC_FOLDER)/pif_to_posit.sv \
	$(SRC_FOLDER)/input_conditioning.sv \
	$(SRC_FOLDER)/handle_special_or_trivial.sv \
	$(SRC_FOLDER)/total_exponent.sv \
	$(SRC_FOLDER)/ops.sv \
	$(SRC_FOLDER)/core_op.sv \
	$(SRC_FOLDER)/core_add_sub.sv \
	$(SRC_FOLDER)/core_add.sv \
	$(SRC_FOLDER)/core_sub.sv \
	$(SRC_FOLDER)/core_mul.sv \
	$(SRC_FOLDER)/core_div.sv \
	$(SRC_FOLDER)/fast_reciprocal.sv \
	$(SRC_FOLDER)/reciprocate_lut.sv \
	$(SRC_FOLDER)/reciprocal_approx.sv \
	$(SRC_FOLDER)/newton_raphson.sv \
	$(SRC_FOLDER)/shift_fields.sv \
	$(SRC_FOLDER)/unpack_exponent.sv \
	$(SRC_FOLDER)/compute_rounding.sv \
	$(SRC_FOLDER)/posit_unpack.sv \
	$(SRC_FOLDER)/posit_decoder.sv \
	$(SRC_FOLDER)/posit_encoder.sv \
	$(SRC_FOLDER)/cls.sv \
	$(SRC_FOLDER)/round_posit.sv \
	$(SRC_FOLDER)/sign_decisor.sv \
	$(SRC_FOLDER)/set_sign.sv \
	$(SRC_FOLDER)/highest_set.sv \
	$(SRC_CONVERSIONS_PPU)

SRC_DIV_AGAINST_PACOGEN := \
	$(SRC_PPU_CORE_OPS) \
	$(SRC_PACOGEN)/common.v \
	$(SRC_PACOGEN)/div/posit_div.v \
	$(SRC_FOLDER)/comparison_against_pacogen.sv 

SRC_FLOAT_TO_POSIT := \
	$(SRC_FOLDER)/utils.sv \
	$(SRC_FOLDER)/common.sv \
	$(SRC_FOLDER)/conversions/defines.vh \
	$(SRC_FOLDER)/conversions/float_to_posit.sv \
	$(SRC_FOLDER)/conversions/float_decoder.sv \
	$(SRC_FOLDER)/pif_to_posit.sv \
	$(SRC_FOLDER)/posit_encoder.sv \
	$(SRC_FOLDER)/round_posit.sv \
	$(SRC_FOLDER)/shift_fields.sv \
	$(SRC_FOLDER)/compute_rounding.sv \
	$(SRC_FOLDER)/unpack_exponent.sv \
	$(SRC_FOLDER)/set_sign.sv
	
SRC_POSIT_TO_FLOAT := \
	$(SRC_FOLDER)/utils.sv \
	$(SRC_FOLDER)/common.sv \
	$(SRC_FOLDER)/conversions/defines.vh \
	$(SRC_FOLDER)/conversions/posit_to_float.sv \
	$(SRC_FOLDER)/conversions/pif_to_float.sv \
	$(SRC_FOLDER)/conversions/float_encoder.sv \
	$(SRC_FOLDER)/conversions/cast_posit_exponent_to_float_exponent.sv \
	$(SRC_FOLDER)/posit_to_pif.sv \
	$(SRC_FOLDER)/posit_decoder.sv \
	$(SRC_FOLDER)/posit_unpack.sv \
	$(SRC_FOLDER)/total_exponent.sv \
	$(SRC_FOLDER)/cls.sv \
	$(SRC_FOLDER)/highest_set.sv


gen-test-vectors:
	cd scripts && \
	python tb_gen.py --num-tests $(NUM_TESTS_PPU) --operation ppu -n 5  -es 1 && \
	python tb_gen.py --num-tests $(NUM_TESTS_PPU) --operation ppu -n 8  -es 0 && \
	python tb_gen.py --num-tests $(NUM_TESTS_PPU) --operation ppu -n 8  -es 4 && \
	python tb_gen.py --num-tests $(NUM_TESTS_PPU) --operation ppu -n 16 -es 1 && \
	python tb_gen.py --num-tests $(NUM_TESTS_PPU) --operation ppu -n 32 -es 2 

ppu-core_ops:
	cd scripts && python tb_gen.py --num-tests $(NUM_TESTS_PPU) --operation ppu -n $(N) -es $(ES) --shuffle-random
	cd waveforms && \
	iverilog -g2012 -DTEST_BENCH_ppu_core_ops \
	$(ES_FIELD_PRESENCE_FLAG) $(FLOAT_TO_POSIT_FLAG) \
	-DN=$(N) -DES=$(ES) \
	-o ppu_core_ops_P$(N)E$(ES).out \
	$(SRC_PPU_CORE_OPS) && \
	sleep 1 && \
	./ppu_core_ops_P$(N)E$(ES).out

ppu-core_ops8:
	make ppu-core_ops N=8 ES=0 F=-1

ppu-core_ops16:
	make ppu-core_ops N=16 ES=1 F=-1

ppu-core_ops32:
	make ppu-core_ops N=32 ES=2 F=-1


conversions:
	cd waveforms && \
	iverilog -g2012 \
	-DN=$(N) $(ES_FIELD_PRESENCE_FLAG) -DES=$(ES) -DF=$(F) \
	-DTB_FLOAT_TO_POSIT \
	-o float_to_posit.out \
	$(SRC_FLOAT_TO_POSIT) && \
	./float_to_posit.out && \
	iverilog -g2012 \
	-DN=$(N) $(ES_FIELD_PRESENCE_FLAG) -DES=$(ES) -DF=$(F) \
	-DTB_POSIT_TO_FLOAT \
	-o posit_to_float.out \
	$(SRC_POSIT_TO_FLOAT) && \
	./posit_to_float.out


conversions-verilog-posit-to-float-quartus:
	cd quartus && \
	sv2v -DN=$(N) $(ES_FIELD_PRESENCE_FLAG) -DES=$(ES) -DF=$(F) \
	$(SRC_POSIT_TO_FLOAT) \
	> posit_to_float.v && cp posit_to_float.v ppu.v

conversions-verilog-float-to-posit-quartus:
	cd quartus && \
	sv2v -DN=$(N) $(ES_FIELD_PRESENCE_FLAG) -DES=$(ES) -DF=$(F) \
	$(SRC_FLOAT_TO_POSIT) \
	> float_to_posit.v && cp float_to_posit.v ppu.v
	

yosys:
	cd waveforms && \
	yosys -DN=16 -DES=1 -p "synth_intel -family max10 -top ppu_core_ops -vqm ppu_core_ops.vqm" \
	$(SRC_PPU_CORE_OPS) > yosys_ppu_core_ops.out

verilog-quartus:
	cd quartus && \
	sv2v \
	$(ES_FIELD_PRESENCE_FLAG) $(FLOAT_TO_POSIT_FLAG) \
	-DN=$(N) -DES=$(ES) -DF=$(F) \
	$(SRC_FOLDER)/ppu.sv \
	$(SRC_PPU_CORE_OPS) > ./ppu.v && iverilog ppu.v && ./a.out


verilog-quartus16:
	make verilog-quartus N=16 ES=0 F=-1


lint:
	slang quartus/ppu.v --top ppu_core_ops # https://github.com/MikePopoloski/slang


div-against-pacogen:
	cd scripts && python tb_gen.py --operation pacogen -n $(N) -es $(ES) --num-tests 3000 --shuffle-random
	cd waveforms && \
	iverilog -g2012 -DN=$(N) -DES=$(ES) -DNR=$(NR_STAGES) $(ES_FIELD_PRESENCE_FLAG) -DTEST_BENCH_COMP_PACOGEN -o comparison_against_pacogen$(N).out \
	$(SRC_DIV_AGAINST_PACOGEN) \
	&& ./comparison_against_pacogen$(N).out > comparison_against_pacogen$(N).log
	cd scripts && python pacogen_log_stats.py -n $(N) -es $(ES)

div-against-pacogen8:
	make div-against-pacogen N=8 ES=0 F=-1

div-against-pacogen16:
	make div-against-pacogen N=16 ES=1 F=-1

div-against-pacogen32:
	make div-against-pacogen N=32 ES=2 F=-1

clean:
	rm waveforms/*.out
	
open-waveforms:
	gtkwave waveforms/tb_ppu_P8E0.gtkw &
	gtkwave waveforms/tb_ppu_P16E1.gtkw &
	gtkwave waveforms/tb_ppu_P32E2.gtkw &
	gtkwave waveforms/tb_comparison_against_pacogenP8E0.gtkw &
	gtkwave waveforms/tb_comparison_against_pacogenP16E1.gtkw &
	gtkwave waveforms/tb_comparison_against_pacogenP32E2.gtkw &

modelsim:
	cd modelsim && \
	vlog ../src/cls.sv ../src/utils.sv
	#do ppu_core_ops.do
