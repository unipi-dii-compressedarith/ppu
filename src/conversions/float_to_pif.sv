module float_to_pif #(
        parameter FSIZE = 64
    )(
        input [FSIZE-1:0] bits,
        output [(1 + FLOAT_EXP_SIZE_F`F + FLOAT_MANT_SIZE_F`F)-1:0] pif
    );

    wire sign;
    wire signed [FLOAT_EXP_SIZE_F`F-1:0] exp;
    wire [FLOAT_MANT_SIZE_F`F-1:0] frac;

    float_decoder #(
        .FSIZE(FSIZE)
    ) float_decoder_inst (
        .bits(bits),
        .sign(sign),
        .exp(exp),
        .frac(frac)
    );

    assign pif = {sign, exp, frac};
    
endmodule
