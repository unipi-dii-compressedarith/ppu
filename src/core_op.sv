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
        input sign1, sign2,
        input [TE_SIZE-1:0] te1, te2,
        input [MANT_SIZE-1:0] mant1, mant2,

        output [TE_SIZE-1:0] te_out_core_op,
        output [(FRAC_FULL_SIZE)-1:0] mant_out_core_op
    );

    wire [(MANT_ADD_RESULT_SIZE)-1:0]   mant_out_add_sub;
    wire [(MANT_MUL_RESULT_SIZE)-1:0]   mant_out_mul;
    wire [(MANT_DIV_RESULT_SIZE)-1:0]   mant_out_div;


    wire [TE_SIZE-1:0] te_out_add_sub, te_out_mul, te_out_div;


    core_add_sub #(
        .N(N)
    ) core_add_sub_inst (
        .te1_in(te1),
        .te2_in(te2),
        .mant1_in(mant1),
        .mant2_in(mant2),
        .have_opposite_sign(sign1 ^ sign2),
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

    core_div #(
        .N(N)
    ) core_div_inst (
        .te1(te1),
        .te2(te2),
        .mant1(mant1),
        .mant2(mant2),
        .mant_out(mant_out_div),
        .te_out(te_out_div)
    );

    assign mant_out_core_op = (op == ADD || op == SUB) 
        ? {mant_out_add_sub, {FRAC_FULL_SIZE-MANT_ADD_RESULT_SIZE{1'b0}}} : op == MUL 
        ? {mant_out_mul, {FRAC_FULL_SIZE-MANT_MUL_RESULT_SIZE{1'b0}}} : /* op == DIV */
          mant_out_div;
    

    assign te_out_core_op = (op == ADD || op == SUB)
        ? te_out_add_sub : op == MUL 
        ? te_out_mul : /* op == DIV */
          te_out_div;

endmodule
