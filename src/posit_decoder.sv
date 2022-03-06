module posit_decoder #(
        parameter N = 4,  // dummy
        parameter ES = 0  // dummy
    )(
        input [N-1:0] bits,
/////////////
        output sign,
        output [TE_SIZE-1:0] te,
        output [MANT_SIZE-1:0] mant
    );

    posit_unpack #(
        .N(N),
        .ES(ES)
    ) posit_unpack_inst (
        .bits           (bits),

        .sign           (sign),
        .reg_s          (),
        .reg_len        (),
        .k              (k),
`ifndef NO_ES_FIELD
        .exp            (exp),
`endif
        .mant           (mant)
    );


    wire [K_SIZE-1:0] k;
`ifndef NO_ES_FIELD
    wire [ES-1:0] exp;
`endif

    total_exponent #(
        .N(N),
        .ES(ES)
    ) total_exponent_inst (
        .k(k),
`ifndef NO_ES_FIELD
        .exp(exp),
`endif
        .total_exp(te)
    );


endmodule
