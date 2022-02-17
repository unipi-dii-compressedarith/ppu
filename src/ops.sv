module ops #(
        parameter N = 4
    )(
        input [OP_SIZE-1:0] op,
        input sign1, sign2,
        input [TE_SIZE-1:0] te1, te2,
        input [MANT_SIZE-1:0] mant1, mant2,
        
        output sign_out,
        output [TE_SIZE-1:0] te_out,
        output [(3*MANT_SIZE)-1:0] mant_out
    );



    wire sign1_cond;
    wire sign2_cond;
    wire [(TE_SIZE)-1:0] te1_cond;
    wire [(TE_SIZE)-1:0] te2_cond;
    wire [(MANT_SIZE)-1:0] mant1_cond;
    wire [(MANT_SIZE)-1:0] mant2_cond;

    wire p2_larger_than_p1;
    input_conditioning #(
        .N(N)
    ) input_conditioning_inst (
        .op(op),
        .sign1_in(sign1), 
        .sign2_in(sign2),
        .te1_in(te1),
        .te2_in(te2),
        .mant1_in(mant1),
        .mant2_in(mant2),

        .p2_larger_than_p1(p2_larger_than_p1),
        .sign1_out(sign1_cond), 
        .sign2_out(sign2_cond),
        .te1_out(te1_cond),
        .te2_out(te2_cond),
        .mant1_out(mant1_cond),
        .mant2_out(mant2_cond)
    );



    core_op #(
        .N(N)
    ) core_op_inst (
        .op(op),
        .sign1(sign1_cond),
        .sign2(sign2_cond),
        .te1(te1_cond),
        .te2(te2_cond),
        .mant1(mant1_cond),
        .mant2(mant2_cond),
        .te_out(te_out),
        .mant_out(mant_out)
    );

    sign_decisor sign_decisor_inst (
        .sign1(sign1_cond),
        .sign2(sign2_cond),
        .op(op),
        .sign(sign_out)
    );


endmodule
