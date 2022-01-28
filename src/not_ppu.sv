/*


iverilog -g2012 -DTEST_BENCH_MUL              -DN=16 -DES=1  -o not_ppu.out \
../src/round_not_ppu.sv \
../src/mul_special.sv \
../src/either_is_special.sv \
../src/not_ppu.sv \
../src/utils.sv \
../src/mul_core.sv \
../src/posit_decode.sv \
../src/posit_encode.sv \
../src/cls.sv \
../src/highest_set.sv \
&& ./not_ppu.out

*/

module not_ppu #(
        parameter N = `N,
        parameter ES = `ES
    )(
        input [N-1:0] p1,
        input [N-1:0] p2,
        output [N-1:0] pout
    );


    unpack_posit #(
        .N(N),
        .ES(ES)
    ) unpack_posit_inst (
        .bits(bits),
        .k(k),
        .exp(exp),
        .frac(frac)
    );


    total_exponent #(
        .N(N),
        .ES(ES)
    ) total_exponent_inst (
        .k(k),
        .exp(exp),
        .total_exp(total_exp)
    );

    core_op #(

    ) core_op_inst (

    );



endmodule



`ifdef TEST_BENCH_NOT_PPU

module tb_not_ppu;

endmodule
`endif
