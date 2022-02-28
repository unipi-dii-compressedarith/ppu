all: \
	gen-test-vectors \
	not-ppu8 \
	not-ppu16 \
	not-ppu32 \
	div-against-pacogen8 \
	div-against-pacogen16 \
	div-against-pacogen32 \
	verilog-quartus16 \
	lint 

.PHONY : all


ifeq ($(ES),0)
ES_FIELD_PRESENCE_FLAG := -DNO_ES_FIELD
endif


NUM_TESTS_PPU := 500

SRC_FOLDER := ../src
SRC_PACOGEN := ../../PaCoGen
SRC_NOT_PPU := \
	$(SRC_FOLDER)/utils.sv \
	$(SRC_FOLDER)/constants.vh \
	$(SRC_FOLDER)/common.sv \
	$(SRC_FOLDER)/not_ppu.sv \
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
	$(SRC_FOLDER)/highest_set.sv

SRC_DIV_AGAINST_PACOGEN := \
	$(SRC_NOT_PPU) \
	$(SRC_FOLDER)/comparison_against_pacogen.sv \
	$(SRC_PACOGEN)/common.v \
	$(SRC_PACOGEN)/div/posit_div.v


gen-test-vectors:
	cd scripts && \
	python tb_gen.py --num-tests $(NUM_TESTS_PPU) --operation ppu -n 5  -es 1 && \
	python tb_gen.py --num-tests $(NUM_TESTS_PPU) --operation ppu -n 8  -es 0 && \
	python tb_gen.py --num-tests $(NUM_TESTS_PPU) --operation ppu -n 16 -es 1 && \
	python tb_gen.py --num-tests $(NUM_TESTS_PPU) --operation ppu -n 32 -es 2 

not-ppu:
	cd scripts && python tb_gen.py --num-tests $(NUM_TESTS_PPU) --operation ppu -n $(N) -es $(ES) --shuffle-random && cd ..
	cd waveforms && \
	iverilog -g2012 -DTEST_BENCH_NOT_PPU $(ES_FIELD_PRESENCE_FLAG) -DN=$(N) -DES=$(ES) -o not_ppu_P$(N)E$(ES).out \
	$(SRC_NOT_PPU) && \
	sleep 1 && \
	./not_ppu_P$(N)E$(ES).out

not-ppu8:
	make not-ppu N=8 ES=0

not-ppu16:
	make not-ppu N=16 ES=1

not-ppu32:
	make not-ppu N=32 ES=2


conversions:
	cd waveforms && \
	iverilog -g2012 \
	-DN=$(N) -DES=$(ES) -DF=$(F) \
	-DTB_FLOAT_TO_POSIT \
	-o float_to_posit.out \
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
	$(SRC_FOLDER)/set_sign.sv && \
	./float_to_posit.out


conversions-verilog-quartus:
	cd quartus && \
	sv2v -DN=$(N) -DES=$(ES) -DF=$(F) \
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
	$(SRC_FOLDER)/set_sign.sv \
	> float_to_posit.v && cp float_to_posit.v ppu.v

yosys:
	cd waveforms && \
	yosys -DN=16 -DES=1 -p "synth_intel -family max10 -top not_ppu -vqm not_ppu.vqm" \
	$(SRC_NOT_PPU) > yosys_not_ppu.out

verilog-quartus:
	cd quartus && \
	sv2v $(ES_FIELD_PRESENCE_FLAG) -DN=$(N) -DES=$(ES)  \
	$(SRC_FOLDER)/ppu.sv \
	$(SRC_NOT_PPU) > ./ppu.v && iverilog ppu.v && ./a.out


verilog-quartus16:
	make verilog-quartus N=16 ES=0


lint:
	slang quartus/ppu.v --top not_ppu # https://github.com/MikePopoloski/slang


div-against-pacogen:
	cd scripts && python tb_gen.py --operation pacogen -n $(N) -es $(ES) --num-tests 3000 --shuffle-random
	cd waveforms && \
	iverilog -g2012 -DN=$(N) -DES=$(ES) -DNR=$(ES) $(ES_FIELD_PRESENCE_FLAG) -DTEST_BENCH_COMP_PACOGEN -o comparison_against_pacogen$(N).out \
	$(SRC_DIV_AGAINST_PACOGEN) \
	&& ./comparison_against_pacogen$(N).out > comparison_against_pacogen$(N).log
	cd scripts && python pacogen_log_stats.py -n $(N) -es $(ES)

div-against-pacogen8:
	make div-against-pacogen N=8 ES=0

div-against-pacogen16:
	make div-against-pacogen N=16 ES=1

div-against-pacogen32:
	make div-against-pacogen N=32 ES=2

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
	#do not_ppu.do
