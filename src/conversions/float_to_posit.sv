module float_to_posit #(
        parameter N = 10,
        parameter ES = 0,
        parameter FSIZE = 32,
        parameter EXP_SIZE = 11,
        parameter MANT_SIZE = 52
    )(
        input [FSIZE-1:0] float,
        output [N-1:0] posit  
    );


    float_decoder #(
        .FSIZE(FSIZE),
        .EXP_SIZE(EXP_SIZE),
        .MANT_SIZE(MANT_SIZE),
    ) float_decoder_inst (
        .bits(float),
        .sign(sign),
        .exp(exp),
        .frac(frac)
    );


    wire [TE_SIZE-1:0] exp;
    
    wire [FRAC_FULL_SIZE-1:0] frac_full;
    assign frac_full = frac >> (MANT_SIZE - FRAC_FULL_SIZE);

    pif_to_posit #(
        .N(N),
        .ES(ES)
    ) pif_to_posit_inst (
        .te(exp),
        .frac_full(frac_full),
        .frac_lsb_cut_off(1'b0),
        .posit(posit)
    );


endmodule



`ifdef TB_FLOAT_TO_POSIT
module tb_float_to_posit;



endmodule
`endif