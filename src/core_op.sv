/*

sv2v -DN=16 -DES=1 \
    ../src/core_op.sv \
    ../src/core_mul.sv \
    ../src/utils.sv \
    ../src/utils.sv > core_op.v && iverilog core_op.v

*/

module core_op #(
        parameter N = `N
    )(
        input [OP_SIZE-1:0] op,
        
        input [TE_SIZE-1:0] te1, te2,
        input [MANT_SIZE-1:0] mant1, mant2,
        input have_opposite_sign,

        output [TE_SIZE-1:0] te_out,
        output [2*MANT_SIZE-1:0] mant_out
    );


    wire [2*MANT_SIZE-1:0] mant_out_add_sub, mant_out_mul, mant_out_div;
    wire [TE_SIZE-1:0] te_out_add_sub, te_out_mul, te_out_div;


    core_add_sub #(
        .N(N)
    ) core_add_sub_inst (
        .te1(te1),
        .te2(te2),
        .mant1(mant1),
        .mant2(mant2),
        .have_opposite_sign(have_opposite_sign),
        .mant_out(mant_out_add_sub),
        .te_out(te_out_add_sub)
    );

    core_mul #(
        .N(N)
    ) core_mul_inst (
        .te1(te1),
        .te2(te2),
        .mant1(mant1),
        .mant2(mant2),
        .mant_out(mant_out_mul),
        .te_out(te_out_mul)
    );

    // core_div #(
    //     .N(N)
    // ) core_div_inst (
    //     .te1(te1),
    //     .te2(te2),
    //     .mant1(mant1),
    //     .mant2(mant2),
    //     .mant_out(mant_out_div),
    //     .te_out(te_out_div)
    // );

    assign mant_out = mant_out_mul;
    assign te_out = te_out_mul;

endmodule
