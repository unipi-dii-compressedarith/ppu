gen-test-vectors:
	cd scripts && \
	python tb_gen.py --num-tests 1000 --operation mul -n 8  -es 0 && \
	python tb_gen.py --num-tests 1000 --operation mul -n 16 -es 1 && \
	python tb_gen.py --num-tests 1000 --operation mul -n 32 -es 2 && \
	python tb_gen.py --num-tests 1000 --operation ppu -n 5  -es 1 && \
	python tb_gen.py --num-tests 1000 --operation ppu -n 8  -es 0 && \
	python tb_gen.py --num-tests 1000 --operation ppu -n 16 -es 1 
	# python tb_gen.py --num-tests 1000 --operation ppu -n 32 -es 2


not-ppu16:
	cd scripts && python tb_gen.py --num-tests 500 --operation ppu -n 16 -es 1 --shuffle-random true && cd ..
	cd waveforms && \
	iverilog -g2012 -DTEST_BENCH_NOT_PPU              -DN=16 -DES=1 -o not_ppu.out \
	../src/utils.sv \
	../src/constants.sv \
	../src/common.sv \
	../src/not_ppu.sv \
	../src/input_conditioning.sv \
	../src/unpack_posit.sv \
	../src/check_special.sv \
	../src/handle_special.sv \
	../src/total_exponent.sv \
	../src/core_op.sv \
	../src/core_add_sub.sv \
	../src/core_add.sv \
	../src/core_sub.sv \
	../src/core_mul.sv \
	../src/core_div.sv \
	../src/fast_reciprocal.sv \
	../src/reciprocal_approx.sv \
	../src/newton_raphson.sv \
	../src/shift_fields.sv \
	../src/unpack_exponent.sv \
	../src/compute_rounding.sv \
	../src/posit_decode.sv \
	../src/posit_encode.sv \
	../src/cls.sv \
	../src/round.sv \
	../src/sign_decisor.sv \
	../src/set_sign.sv \
	../src/highest_set.sv && \
	sleep 1 && \
	./not_ppu.out # https://github.com/steveicarus/iverilog 

not-ppu8:
	cd scripts && python tb_gen.py --num-tests 500 --operation ppu -n 8 -es 0 --shuffle-random false && cd ..
	cd waveforms && \
	iverilog -g2012 -DTEST_BENCH_NOT_PPU -DNO_ES_FIELD -DN=8 -DES=0 -o not_ppu.out \
	../src/utils.sv \
	../src/constants.sv \
	../src/common.sv \
	../src/not_ppu.sv \
	../src/input_conditioning.sv \
	../src/unpack_posit.sv \
	../src/check_special.sv \
	../src/handle_special.sv \
	../src/total_exponent.sv \
	../src/core_op.sv \
	../src/core_add_sub.sv \
	../src/core_add.sv \
	../src/core_sub.sv \
	../src/core_mul.sv \
	../src/core_div.sv \
	../src/fast_reciprocal.sv \
	../src/reciprocal_approx.sv \
	../src/newton_raphson.sv \
	../src/shift_fields.sv \
	../src/unpack_exponent.sv \
	../src/compute_rounding.sv \
	../src/posit_decode.sv \
	../src/posit_encode.sv \
	../src/cls.sv \
	../src/round.sv \
	../src/sign_decisor.sv \
	../src/set_sign.sv \
	../src/highest_set.sv && \
	sleep 1 && \
	./not_ppu.out # https://github.com/steveicarus/iverilog 

yosys:
	cd waveforms && \
	yosys -DN=16 -DES=1 -p "synth_intel -family max10 -top not_ppu -vqm not_ppu.vqm" \
	../src/common.sv \
	../src/utils.sv \
	../src/constants.sv \
	../src/not_ppu.sv \
	../src/input_conditioning.sv \
	../src/unpack_posit.sv \
	../src/check_special.sv \
	../src/handle_special.sv \
	../src/total_exponent.sv \
	../src/core_op.sv \
	../src/core_add_sub.sv \
	../src/core_add.sv \
	../src/core_sub.sv \
	../src/core_mul.sv \
	../src/core_div.sv \
	../src/fast_reciprocal.sv \
	../src/reciprocal_approx.sv \
	../src/newton_raphson.sv \
	../src/shift_fields.sv \
	../src/unpack_exponent.sv \
	../src/compute_rounding.sv \
	../src/posit_decode.sv \
	../src/posit_encode.sv \
	../src/cls.sv \
	../src/round.sv \
	../src/sign_decisor.sv \
	../src/set_sign.sv \
	../src/highest_set.sv > yosys_not_ppu.out # https://github.com/YosysHQ/yosys

verilog-quartus16:
	cd quartus && \
	sv2v             -DN=16 -DES=1  \
	../src/utils.sv \
	../src/constants.sv \
	../src/common.sv \
	../src/ppu.sv \
	../src/not_ppu.sv \
	../src/input_conditioning.sv \
	../src/unpack_posit.sv \
	../src/check_special.sv \
	../src/handle_special.sv \
	../src/total_exponent.sv \
	../src/core_op.sv \
	../src/core_add_sub.sv \
	../src/core_add.sv \
	../src/core_sub.sv \
	../src/core_mul.sv \
	../src/core_div.sv \
	../src/fast_reciprocal.sv \
	../src/reciprocal_approx.sv \
	../src/newton_raphson.sv \
	../src/shift_fields.sv \
	../src/unpack_exponent.sv \
	../src/compute_rounding.sv \
	../src/posit_decode.sv \
	../src/posit_encode.sv \
	../src/cls.sv \
	../src/round.sv \
	../src/sign_decisor.sv \
	../src/set_sign.sv \
	../src/highest_set.sv > ./ppu.v # https://github.com/zachjs/sv2v && \
	iverilog ppu.v

verilog-quartus8:
	cd quartus && \
	sv2v -DNO_ES_FIELD -DN=8 -DES=0  \
	../src/utils.sv \
	../src/constants.sv \
	../src/common.sv \
	../src/ppu.sv \
	../src/not_ppu.sv \
	../src/input_conditioning.sv \
	../src/unpack_posit.sv \
	../src/check_special.sv \
	../src/handle_special.sv \
	../src/total_exponent.sv \
	../src/core_op.sv \
	../src/core_add_sub.sv \
	../src/core_add.sv \
	../src/core_sub.sv \
	../src/core_mul.sv \
	../src/core_div.sv \
	../src/fast_reciprocal.sv \
	../src/reciprocal_approx.sv \
	../src/newton_raphson.sv \
	../src/shift_fields.sv \
	../src/unpack_exponent.sv \
	../src/compute_rounding.sv \
	../src/posit_decode.sv \
	../src/posit_encode.sv \
	../src/cls.sv \
	../src/round.sv \
	../src/sign_decisor.sv \
	../src/set_sign.sv \
	../src/highest_set.sv > ./ppu.v # https://github.com/zachjs/sv2v && \
	iverilog ppu.v

lint:
	slang quartus/not_ppu.v # https://github.com/MikePopoloski/slang

div-against-pacogen-p16:
	cd scripts && python tb_gen.py --operation pacogen -n 16 -es 1 --num-tests 3000 --shuffle-random true
	cd waveforms && iverilog -g2012 -DN=16 -DES=1 -DNR=1 -DTEST_BENCH_COMP_PACOGEN -o comparison_against_pacogen.out \
	../src/utils.sv \
	../src/constants.sv \
	../src/common.sv \
	../src/comparison_against_pacogen.sv \
	../src/not_ppu.sv \
	../src/input_conditioning.sv \
	../src/unpack_posit.sv \
	../src/check_special.sv \
	../src/handle_special.sv \
	../src/total_exponent.sv \
	../src/core_op.sv \
	../src/core_add_sub.sv \
	../src/core_add.sv \
	../src/core_sub.sv \
	../src/core_mul.sv \
	../src/core_div.sv \
	../src/fast_reciprocal.sv \
	../src/reciprocal_approx.sv \
	../src/newton_raphson.sv \
	../src/shift_fields.sv \
	../src/unpack_exponent.sv \
	../src/compute_rounding.sv \
	../src/posit_decode.sv \
	../src/posit_encode.sv \
	../src/cls.sv \
	../src/round.sv \
	../src/sign_decisor.sv \
	../src/set_sign.sv \
	../src/highest_set.sv \
	../../PACoGen/common.v \
	../../PACoGen/div/posit_div.v \
	&& ./comparison_against_pacogen.out > comparison_against_pacogen.log
	cd scripts && python pacogen_log_stats.py
