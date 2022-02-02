module core_div #(
        parameter N = 16
    )(
        input [TE_SIZE-1:0] te1,
        input [TE_SIZE-1:0] te2,
        input [MANT_SIZE-1:0] mant1,
        input [MANT_SIZE-1:0] mant2,
        output [(2*MANT_SIZE)-1:0] mant_out,
        output [TE_SIZE-1:0] te_out
    );

    wire [TE_SIZE-1:0] te_diff;
    assign te_diff = te1 - te2;

    wire [(2*MANT_SIZE)-1:0] mant_div;
    
    //// assign mant_div = (mant1 << (2 * size - 1)) / mant2;


    wire [MANT_SIZE-1:0] mant2_reciprocal;

    unsigned_reciprocal_approx #(
    ) unsigned_reciprocal_approx_inst (
        .i_data(mant2),
        .o_data(mant2_reciprocal)
    );



    wire [MANT_SIZE-1:0] x1;

    newton_raphson #(
        .SIZE(MANT_SIZE)
    ) newton_raphson_inst (
        .num(mant2),
        .x0(mant2_reciprocal),
        .x1(x1)
    );

    assign mant_div = mant1 * x1;


    
    assign mant_out = mant1 < mant2 ? mant_div << 1 : mant_div;
    assign te_out = mant1 < mant2 ? te_diff - 1 : te_diff;

endmodule
