module core_div #(
        parameter N = 16
    )(
        input te1
        input te2
        input mant1,
        input mant2,
        output mant_out,
        output te_out
    );

    wire te_diff;
    assign te_diff = te1 - te2;

    wire mant_div;
    assign mant_div = (mant1 << (2 * size - 1)) / mant2;
    
    
    
    assign mant_out = mant1 < mant2 ? mant_div << 1 : mant_div;
    assign te_out = mant1 < mant2 ? te_diff - 1 : te_diff;

endmodule
