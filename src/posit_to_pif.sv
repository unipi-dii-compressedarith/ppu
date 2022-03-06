module posit_to_pif #(
        parameter N = 4,
        parameter ES = 0
    )(
        input   [N-1:0]         p_cond,
        output  [PIF_SIZE-1:0]  pif
    );


    wire                 sign;
    wire [TE_SIZE-1:0]   te;
    wire [MANT_SIZE-1:0] mant;

    posit_decoder #(
        .N(N),
        .ES(ES)
    ) posit_decoder_inst (
        .bits(p_cond),
/////////////
        .sign(sign),
        .te(te),
        .mant(mant)
    );

    assign pif = {sign, te, mant};

endmodule
