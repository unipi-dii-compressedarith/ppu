module posit_to_float #(
        parameter N = 10,
        parameter ES = 0,
        parameter FSIZE = 32,
        parameter EXP_SIZE = 11,
        parameter MANT_SIZE = 52
    )(
        input [N-1:0] posit,
        output [FSIZE-1:0] float
    );


    posit_to_pif #(
        .N(N),
        .ES(ES)
    ) posit_to_pif_inst (
        .p_cond(p_cond),
        .pif(pif)
    );



    float_encoder #(
        .FSIZE(FSIZE),
        .EXP_SIZE(EXP_SIZE),
        .MANT_SIZE(MANT_SIZE),
    ) float_encoder_inst (
        .bits(float),
        .sign(sign),
        .exp(exp),
        .frac(frac)
    );


    

endmodule



`ifdef TB_FLOAT_TO_POSIT
module tb_float_to_posit;



endmodule
`endif