cd scripts
python tb_gen.py --operation mul -n 8  -es 0
python tb_gen.py --operation mul -n 16 -es 1
python tb_gen.py --operation mul -n 32 -es 2
python tb_gen.py --operation mul -n 5 -es 1 # to be fixed in posit_playground



cd ..
cd waveforms


iverilog -g2012 -DTEST_BENCH_MUL -DNO_ES_FIELD -DN=8 -DES=0  -o mul.out \
../src/round_mul.sv \
../src/mul.sv \
../src/mul_special.sv \
../src/either_is_special.sv \
../src/utils.sv \
../src/mul_core.sv \
../src/posit_decode.sv \
../src/posit_encode.sv \
../src/cls.sv \
../src/highest_set.sv \
&& ./mul.out


iverilog -g2012 -DTEST_BENCH_MUL              -DN=16 -DES=1  -o mul.out \
../src/round_mul.sv \
../src/mul_special.sv \
../src/either_is_special.sv \
../src/mul.sv \
../src/utils.sv \
../src/mul_core.sv \
../src/posit_decode.sv \
../src/posit_encode.sv \
../src/cls.sv \
../src/highest_set.sv \
&& ./mul.out

iverilog -g2012 -DTEST_BENCH_MUL              -DN=32 -DES=2  -o mul.out \
../src/round_mul.sv \
../src/mul_special.sv \
../src/either_is_special.sv \
../src/mul.sv \
../src/utils.sv \
../src/mul_core.sv \
../src/posit_decode.sv \
../src/posit_encode.sv \
../src/cls.sv \
../src/highest_set.sv \
&& ./mul.out




cd ..
cd quartus

sv2v -DN=16 -DES=1 \
../src/mul.sv \
../src/mul_core.sv \
../src/round_mul.sv \
../src/posit_decode.sv \
../src/posit_encode.sv \
../src/utils.sv \
../src/cls.sv \
../src/highest_set.sv > mul.v

cd ..
