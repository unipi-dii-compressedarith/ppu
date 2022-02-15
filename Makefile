all : gen-test-vectors not-ppu
.PHONY : all


ifeq ($(ES),0)
ES_FIELD_PRESENCE_FLAG := -DNO_ES_FIELD
endif


NUM_TESTS_PPU := 500

SRC_FOLDER := ../src
SRC_PACOGEN := ../../PaCoGen
SRC_NOT_PPU := \
	$(SRC_FOLDER)/utils.sv \
	$(SRC_FOLDER)/constants.sv \
	$(SRC_FOLDER)/common.sv \
	$(SRC_FOLDER)/not_ppu.sv \
	$(SRC_FOLDER)/input_conditioning.sv \
	$(SRC_FOLDER)/unpack_posit.sv \
	$(SRC_FOLDER)/check_special.sv \
	$(SRC_FOLDER)/handle_special.sv \
	$(SRC_FOLDER)/total_exponent.sv \
	$(SRC_FOLDER)/core_op.sv \
	$(SRC_FOLDER)/core_add_sub.sv \
	$(SRC_FOLDER)/core_add.sv \
	$(SRC_FOLDER)/core_sub.sv \
	$(SRC_FOLDER)/core_mul.sv \
	$(SRC_FOLDER)/core_div.sv \
	$(SRC_FOLDER)/fast_reciprocal.sv \
	$(SRC_FOLDER)/reciprocal_approx.sv \
	$(SRC_FOLDER)/newton_raphson.sv \
	$(SRC_FOLDER)/shift_fields.sv \
	$(SRC_FOLDER)/unpack_exponent.sv \
	$(SRC_FOLDER)/compute_rounding.sv \
	$(SRC_FOLDER)/posit_decode.sv \
	$(SRC_FOLDER)/posit_encode.sv \
	$(SRC_FOLDER)/cls.sv \
	$(SRC_FOLDER)/round.sv \
	$(SRC_FOLDER)/sign_decisor.sv \
	$(SRC_FOLDER)/set_sign.sv \
	$(SRC_FOLDER)/highest_set.sv

SRC_DIV_AGAINST_PACOGEN := \
	$(SRC_NOT_PPU) \
	$(SRC_FOLDER)/comparison_against_pacogen.sv \
	$(SRC_PACOGEN)/common.v \
	$(SRC_PACOGEN)/div/posit_div.v


action:
	echo argument is $(argument)

gen-test-vectors:
	cd scripts && \
	python tb_gen.py --num-tests 1000 --operation mul -n 8  -es 0 && \
	python tb_gen.py --num-tests 1000 --operation mul -n 16 -es 1 && \
	python tb_gen.py --num-tests 1000 --operation mul -n 32 -es 2 && \
	python tb_gen.py --num-tests 1000 --operation ppu -n 5  -es 1 && \
	python tb_gen.py --num-tests 1000 --operation ppu -n 8  -es 0 && \
	python tb_gen.py --num-tests 1000 --operation ppu -n 16 -es 1 
	# python tb_gen.py --num-tests 1000 --operation ppu -n 32 -es 2

not-ppu:
	cd scripts && python tb_gen.py --num-tests $(NUM_TESTS_PPU) --operation ppu -n $(N) -es $(ES) --shuffle-random true && cd ..
	cd waveforms && \
	iverilog -g2012 -DTEST_BENCH_NOT_PPU $(ES_FIELD_PRESENCE_FLAG) -DN=$(N) -DES=$(ES) -o not_ppu_P$(N)E$(ES).out -s tb_not_ppu \
	$(SRC_NOT_PPU) && \
	sleep 1 && \
	./not_ppu_P$(N)E$(ES).out


yosys:
	cd waveforms && \
	yosys -DN=16 -DES=1 -p "synth_intel -family max10 -top not_ppu -vqm not_ppu.vqm" \
	$(SRC_NOT_PPU) > yosys_not_ppu.out

verilog-quartus:
	cd quartus && \
	sv2v $(ES_FIELD_PRESENCE_FLAG) -DN=$(N) -DES=$(ES)  \
	$(SRC_NOT_PPU) > ./not_ppu_P$(N)E$(ES).v && \
	iverilog not_ppu_P$(N)E$(ES).v && ./a.out


lint:
	slang quartus/ppu.v --top not_ppu # https://github.com/MikePopoloski/slang


div-against-pacogen:
	cd scripts && python tb_gen.py --operation pacogen -n $(N) -es $(ES) --num-tests 3000 --shuffle-random true
	cd waveforms && \
	iverilog -g2012 -DN=$(N) -DES=$(ES) -DNR=$(ES) $(ES_FIELD_PRESENCE_FLAG) -DTEST_BENCH_COMP_PACOGEN -o comparison_against_pacogen$(N).out \
	$(SRC_DIV_AGAINST_PACOGEN) \
	&& ./comparison_against_pacogen$(N).out > comparison_against_pacogen$(N).log
	cd scripts && python pacogen_log_stats.py -n $(N) -es $(ES)

div-against-pacogen16:
	cd scripts && python tb_gen.py --operation pacogen -n 16 -es 1 --num-tests 3000 --shuffle-random true
	cd waveforms && \
	iverilog -g2012 -DN=16 -DES=1 -DNR=1 -DTEST_BENCH_COMP_PACOGEN -o comparison_against_pacogen16.out \
	$(SRC_DIV_AGAINST_PACOGEN) \
	&& ./comparison_against_pacogen16.out > comparison_against_pacogen16.log
	cd scripts && python pacogen_log_stats.py -n 16 -es 1


clean:
	rm waveforms/*.out
	
