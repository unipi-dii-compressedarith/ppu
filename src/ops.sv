module ops #(
        parameter N = 4
    )(
        input [OP_SIZE-1:0] op,

        input [PIF_SIZE-1:0] pif1,
        input [PIF_SIZE-1:0] pif2,

        output [(1 + TE_SIZE + FRAC_FULL_SIZE)-1:0] pif_ops_out,
        output frac_lsb_cut_off
    );

    wire sign1, sign2;
    wire [TE_SIZE-1:0] te1, te2;
    wire [MANT_SIZE-1:0] mant1, mant2;
    wire [FRAC_FULL_SIZE-1:0] frac_out;


    wire sign_out;
    wire [TE_SIZE-1:0] te_out;
    wire [FRAC_FULL_SIZE-1:0] frac_full;

    assign {sign1, te1, mant1} = pif1;
    assign {sign2, te2, mant2} = pif2;

    core_op #(
        .N(N)
    ) core_op_inst (
        .op(op),
        .sign1(sign1),
        .sign2(sign2),
        .te1(te1),
        .te2(te2),
        .mant1(mant1),
        .mant2(mant2),
        .te_out_core_op(te_out),
        .frac_out_core_op(frac_out),
        .frac_lsb_cut_off(frac_lsb_cut_off)
    );

    sign_decisor #(
    ) sign_decisor (
        .sign1(sign1),
        .sign2(sign2),
        .op(op),
        .sign(sign_out)
    );

    assign pif_ops_out = {sign_out, te_out, frac_out};

endmodule
