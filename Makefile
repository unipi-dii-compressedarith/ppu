all: \
	ppu8 \
	ppu16 \
	ppu32 \
	div-against-pacogen8 \
	div-against-pacogen16 \
	div-against-pacogen32 \


.PHONY : all modelsim

GREEN='\033[0;32m'
NC='\033[0m' # No Color

SRC_FOLDER := ../src
SRC_PACOGEN := ../../PaCoGen


ifeq ($(ES),0)
ES_FIELD_PRESENCE_FLAG := -DNO_ES_FIELD
endif

ifeq ($(DIV_WITH_LUT),1)
DIV_WITH_LUT_FLAG := -DDIV_WITH_LUT -DLUT_SIZE_IN=$(LUT_SIZE_IN) -DLUT_SIZE_OUT=$(LUT_SIZE_OUT)
else
LUT_SIZE_IN := 8
LUT_SIZE_OUT := 9
endif

ifeq ($(F),0)
else
FLOAT_TO_POSIT_FLAG := -DFLOAT_TO_POSIT -DF=$(F)
SRC_CONVERSIONS_PPU := \
	$(SRC_FOLDER)/conversions/defines.vh \
	$(SRC_FOLDER)/conversions/float_decoder.sv

endif


NR_STAGES := $(ES) 	# newton-raphson stages. actually it's 0 for N in (0..=8), 1 for N in (9..=16), 2 for N in (17..=32)

NUM_TESTS_PPU := 500

SRC_PPU_CORE_OPS := \
	$(SRC_FOLDER)/utils.sv \
	$(SRC_FOLDER)/constants.vh \
	$(SRC_FOLDER)/common.sv \
	$(SRC_FOLDER)/ppu_core_ops.sv \
	$(SRC_FOLDER)/posit_to_fir.sv \
	$(SRC_FOLDER)/fir_to_posit.sv \
	$(SRC_FOLDER)/conversions/float_encoder.sv \
	$(SRC_FOLDER)/conversions/sign_extend.sv \
	$(SRC_FOLDER)/conversions/float_to_fir.sv \
	$(SRC_FOLDER)/conversions/fir_to_float.sv \
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
	$(SRC_FOLDER)/lut.sv \
	$(SRC_FOLDER)/reciprocal_approx.sv \
	$(SRC_FOLDER)/newton_raphson.sv \
	$(SRC_FOLDER)/pack_fields.sv \
	$(SRC_FOLDER)/unpack_exponent.sv \
	$(SRC_FOLDER)/compute_rounding.sv \
	$(SRC_FOLDER)/posit_unpack.sv \
	$(SRC_FOLDER)/posit_decoder.sv \
	$(SRC_FOLDER)/posit_encoder.sv \
	$(SRC_FOLDER)/lzc.sv \
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
	$(SRC_FOLDER)/conversions/float_to_fir.sv \
	$(SRC_FOLDER)/conversions/float_decoder.sv \
	$(SRC_FOLDER)/fir_to_posit.sv \
	$(SRC_FOLDER)/posit_encoder.sv \
	$(SRC_FOLDER)/round_posit.sv \
	$(SRC_FOLDER)/pack_fields.sv \
	$(SRC_FOLDER)/compute_rounding.sv \
	$(SRC_FOLDER)/unpack_exponent.sv \
	$(SRC_FOLDER)/set_sign.sv
	
SRC_POSIT_TO_FLOAT := \
	$(SRC_FOLDER)/utils.sv \
	$(SRC_FOLDER)/common.sv \
	$(SRC_FOLDER)/conversions/defines.vh \
	$(SRC_FOLDER)/conversions/posit_to_float.sv \
	$(SRC_FOLDER)/conversions/fir_to_float.sv \
	$(SRC_FOLDER)/conversions/float_encoder.sv \
	$(SRC_FOLDER)/conversions/sign_extend.sv \
	$(SRC_FOLDER)/posit_to_fir.sv \
	$(SRC_FOLDER)/posit_decoder.sv \
	$(SRC_FOLDER)/posit_unpack.sv \
	$(SRC_FOLDER)/total_exponent.sv \
	$(SRC_FOLDER)/cls.sv \
	$(SRC_FOLDER)/highest_set.sv


gen-test-vectors:
	cd scripts && \
	python tb_gen.py --num-tests $(NUM_TESTS_PPU) --operation ppu -n $(N) -es $(ES) --shuffle-random \
	# python tb_gen.py --num-tests $(NUM_TESTS_PPU) --operation ppu -n 5  -es 1 && \
	# python tb_gen.py --num-tests $(NUM_TESTS_PPU) --operation ppu -n 8  -es 0 && \
	# python tb_gen.py --num-tests $(NUM_TESTS_PPU) --operation ppu -n 8  -es 4 && \
	# python tb_gen.py --num-tests $(NUM_TESTS_PPU) --operation ppu -n 16 -es 1 && \
	# python tb_gen.py --num-tests $(NUM_TESTS_PPU) --operation ppu -n 32 -es 2 

gen-lut-reciprocate-mant:
	python scripts/mant_recip_LUT_gen.py -i $(LUT_SIZE_IN) -o $(LUT_SIZE_OUT) > src/lut.sv 

ppu-core_ops:
	cd scripts && python tb_gen.py --num-tests $(NUM_TESTS_PPU) --operation ppu -n $(N) -es $(ES) --no-shuffle-random
	cd waveforms && \
	iverilog -g2012 -DTEST_BENCH_PPU_CORE_OPS \
	$(ES_FIELD_PRESENCE_FLAG) $(FLOAT_TO_POSIT_FLAG) \
	-DN=$(N) -DES=$(ES) \
	-o ppu_core_ops_P$(N)E$(ES).out \
	$(SRC_PPU_CORE_OPS) && \
	sleep 1 && \
	./ppu_core_ops_P$(N)E$(ES).out


ppu: gen-lut-reciprocate-mant verilog-quartus
	cd scripts && python tb_gen.py --num-tests $(NUM_TESTS_PPU) --operation ppu -n $(N) -es $(ES) --no-shuffle-random
	cd waveforms && \
	iverilog -g2012 -DTEST_BENCH_PPU \
	$(ES_FIELD_PRESENCE_FLAG) \
	$(DIV_WITH_LUT_FLAG) \
	-DWORD=$(WORD) -DN=$(N) -DES=$(ES) $(FLOAT_TO_POSIT_FLAG) -DF=$(F) \
	-o ppu_P$(N)E$(ES).out \
	../src/ppu.sv \
	$(SRC_PPU_CORE_OPS) && \
	sleep 1 && \
	./ppu_P$(N)E$(ES).out
	make lint

ppu8:
	make ppu N=8 ES=0 F=64 WORD=64 DIV_WITH_LUT=0

ppu16:
	make ppu N=16 ES=1 F=64 WORD=64 DIV_WITH_LUT=0

ppu32:
	make ppu N=32 ES=2 F=64 WORD=64 DIV_WITH_LUT=0


conversions:
	cd waveforms && \
	iverilog -g2012 \
	-DN=$(N) $(ES_FIELD_PRESENCE_FLAG) -DES=$(ES) $(FLOAT_TO_POSIT_FLAG) -DF=$(F) \
	-DTB_FLOAT_TO_POSIT \
	-o float_to_posit.out \
	$(SRC_FLOAT_TO_POSIT) && \
	./float_to_posit.out && \
	iverilog -g2012 \
	-DN=$(N) $(ES_FIELD_PRESENCE_FLAG) -DES=$(ES) $(FLOAT_TO_POSIT_FLAG) -DF=$(F) \
	-DTB_POSIT_TO_FLOAT \
	-o posit_to_float.out \
	$(SRC_POSIT_TO_FLOAT) && \
	./posit_to_float.out
	gtkwave waveforms/tb_float_F64_to_posit_P16E1.gtkw &
	gtkwave waveforms/tb_posit_P16E1_to_float_F64.vcd &


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
	cd src && \
	yosys -p "synth_intel -family max10 -top ppu -vqm ppu.vqm" \
	../quartus/ppu_top.v > yosys_ppu.out

sim-yosys:
	make yosys
	sv2v src/ppu.vqm > src/sv2v_ppu.vqm

verilog-quartus:
	cd quartus && \
	sv2v \
	$(ES_FIELD_PRESENCE_FLAG) \
	$(DIV_WITH_LUT_FLAG) -DLUT_SIZE_IN=$(LUT_SIZE_IN) -DLUT_SIZE_OUT=$(LUT_SIZE_OUT) \
	$(FLOAT_TO_POSIT_FLAG) \
	-DWORD=$(WORD) -DN=$(N) -DES=$(ES) -DF=$(F) \
	$(SRC_FOLDER)/ppu_top.sv \
	$(SRC_FOLDER)/ppu.sv \
	$(SRC_PPU_CORE_OPS) > ppu_top.v && iverilog ppu_top.v && ./a.out


verilog-quartus16:
	make verilog-quartus N=16 ES=0 F=0


lint:
	slang quartus/ppu_top.v --top ppu_top # https://github.com/MikePopoloski/slang


div-against-pacogen:
	cd scripts && python tb_gen.py --operation pacogen -n $(N) -es $(ES) --num-tests 3000 --shuffle-random
	cd waveforms && \
	iverilog -g2012 -DN=$(N) -DES=$(ES) -DNR=$(NR_STAGES) $(ES_FIELD_PRESENCE_FLAG) -DTEST_BENCH_COMP_PACOGEN -o comparison_against_pacogen$(N).out \
	$(SRC_DIV_AGAINST_PACOGEN) \
	&& ./comparison_against_pacogen$(N).out > comparison_against_pacogen$(N).log
	cd scripts && python pacogen_log_stats.py -n $(N) -es $(ES)

div-against-pacogen8:
	make div-against-pacogen N=8 ES=0 F=0

div-against-pacogen16:
	make div-against-pacogen N=16 ES=1 F=0

div-against-pacogen32:
	make div-against-pacogen N=32 ES=2 F=0

clean:
	rm waveforms/*.out
	
fmt:
	python scripts/fmt.py # local only

open-waveforms:
	gtkwave waveforms/tb_ppu_P8E0.gtkw &
	gtkwave waveforms/tb_ppu_P16E1.gtkw &
	gtkwave waveforms/tb_ppu_P32E2.gtkw &
	gtkwave waveforms/tb_comparison_against_pacogenP8E0.gtkw &
	gtkwave waveforms/tb_comparison_against_pacogenP16E1.gtkw &
	gtkwave waveforms/tb_comparison_against_pacogenP32E2.gtkw &

modelsim:
	make verilog-quartus N=16 ES=1 WORD=64 F=64
	cp quartus/ppu.v modelsim/ppu.v
	# do ppu.do
