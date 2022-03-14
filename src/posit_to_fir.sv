module posit_to_fir #(
        parameter N = 4,
        parameter ES = 0
    )(
        input   [N-1:0]         p_cond,
        output  [fir_SIZE-1:0]  fir
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

    assign fir = {sign, te, mant};

endmodule
