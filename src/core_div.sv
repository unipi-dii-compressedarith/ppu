module core_div #(
        parameter N = 16
    )(
        input [TE_SIZE-1:0] te1,
        input [TE_SIZE-1:0] te2,
        input [MANT_SIZE-1:0] mant1,
        input [MANT_SIZE-1:0] mant2,
        output [(MANT_DIV_RESULT_SIZE)-1:0] mant_out,
        output [TE_SIZE-1:0] te_out
    );

    wire [TE_SIZE-1:0] te_diff;
    assign te_diff = te1 - te2;

    wire [(MANT_DIV_RESULT_SIZE)-1:0] mant_div;
    
    //// assign mant_div = (mant1 << (2 * size - 1)) / mant2;


    wire [(3*MANT_SIZE-3)-1:0] mant2_reciprocal;


//`define USE_LUT
`ifdef USE_LUT
    reciprocate_lut #(
        .LUT_WIDTH_IN(MANT_SIZE-1),
        .LUT_WIDTH_OUT(MANT_DIV_RESULT_SIZE - 1 - 2)
    ) reciprocate_lut_inst (
        .addr(mant2[MANT_SIZE-2:0]),
        .out(mant2_reciprocal)
    );
`else
    fast_reciprocal #(
        .SIZE(MANT_SIZE)
    ) fast_reciprocal_inst (
        .fraction(mant2),
        .one_over_fraction(mant2_reciprocal)
    );    
`endif
    
    

    wire [(2*MANT_SIZE)-1:0] x1;
    newton_raphson #(
        .MS(MANT_SIZE)
    ) newton_raphson_inst (
        .num(mant2),
        .x0(mant2_reciprocal << 1), // shifted up by one because i drop the "tens" digit in favor on an additional fractional bit
        .x1(x1)
    );

    assign mant_div = mant1 * x1;


    wire mant_div_less_than_one;
    assign mant_div_less_than_one = 
        (mant_div & (1 << (3*MANT_SIZE-2))) == 0;
    
    assign mant_out = 
        mant_div_less_than_one ? mant_div << 1 : mant_div;
    assign te_out = 
        mant_div_less_than_one ? te_diff - 1 : te_diff;

endmodule
