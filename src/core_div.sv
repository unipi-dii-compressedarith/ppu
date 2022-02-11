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


    wire [(3*MANT_SIZE)-1:0] mant2_reciprocal;

    fast_reciprocal #(
        .SIZE(MANT_SIZE)
    ) fast_reciprocal_inst (
        .fraction(mant2),
        .one_over_fraction(mant2_reciprocal)
    );


    wire [(MANT_SIZE)-1:0] x1;

    newton_raphson #(
        .SIZE(MANT_SIZE)
    ) newton_raphson_inst (
        .num(mant2),
        .x0(mant2_reciprocal),
        .x1(x1)
    );

    assign mant_div = mant1 * x1;


    wire mant_div_less_than_one;
    assign mant_div_less_than_one = 
        (mant_div & (1 << (2*N-2))) == 0;
    
    assign mant_out = 
        mant_div_less_than_one ? mant_div << 1 : mant_div;
    assign te_out = 
        mant_div_less_than_one ? te_diff - 1 : te_diff;

endmodule
