/*
Wed Jan 26 16:54:38 CET 2022

cd waveforms

iverilog -g2012 -DTEST_BENCH_UNPACK_POSIT               -DN=16 -DES=1 -o unpack_posit.out \
    ../src/unpack_posit.sv \
    ../src/posit_decode.sv \
    ../src/utils.sv \
    ../src/highest_set.sv \
    ../src/cls.sv \
    && ./unpack_posit.out

sv2v -DN=16 -DES=1 \
    ../src/unpack_posit.sv \
    ../src/posit_decode.sv \
    ../src/utils.sv \
    ../src/highest_set.sv \
    ../src/cls.sv > unpack_posit.v && iverilog unpack_posit.v
*/


module unpack_posit #(
        parameter N = `N,
        parameter ES = `ES
    )(
        input [N-1:0] bits,
        output sign,
        output [K_SIZE-1:0] k,
`ifndef NO_ES_FIELD
        output [ES-1:0] exp,
`endif
        output [MANT_SIZE-1:0] mant // 1.frac
    );

    wire [1:0] is_special;

    posit_decode #(
        .N(N),
        .ES(ES)
    ) posit_decode_inst (
        .bits(bits),
        .sign(sign),
        .reg_s(),
        .reg_len(),
        .k(k),
`ifndef NO_ES_FIELD
        .exp(exp),
`endif
        .mant(mant),
        .is_special(is_special)
    );

endmodule




`ifdef TEST_BENCH_UNPACK_POSIT
module tb_unpack_posit;
endmodule
`endif
