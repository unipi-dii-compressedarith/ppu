temporary file, maybe i can come up with a makefile or something later


inside the scripts folder run the python tb_gen script to generate the test benches

    cd scripts

tb decode 

    python tb_gen.py --operation decode -n 8 -es 0
    python tb_gen.py --operation decode -n 16 -es 1

tb encode

    python tb_gen.py --operation encode -n 8 -es 0


tb mul core

    python tb_gen.py --operation mul_core -n 8 -es 0


---

then go back to the waveforms folder to run iverilog

    cd ..
    cd waveforms

**decode** module

    iverilog -DTEST_BENCH_DECODE -DN=8 -DES=0 -o posit_decode.out \
    ../src/posit_decode.sv \
    ../src/highest_set.sv \
    ../src/cls.sv \
    && ./posit_decode.out

**encode** module

    iverilog -DTEST_BENCH_ENCODE -DN=8 -DES=0 -o posit_encode.out ../src/posit_encode.sv && ./posit_encode.out


**mul core** module

    iverilog -DTEST_BENCH_MUL_CORE -DNO_ES_FIELD -DN=8 -DES=0 -o mul_core ../src/mul_core.sv && ./mul_core
    