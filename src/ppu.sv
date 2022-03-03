module ppu #(
        parameter WORD = 10
    )(
        input [WORD-1:0] in1,
        input [WORD-1:0] in2,
        input            op, /*
                              ADD
                            | SUB
                            | MUL
                            | DIV
                            | F2P
                            | P2F
                            */
        output [WORD-1:0] out
    );

    wire op_is_float_to_posit = (op == FLOAT_TO_POSIT);
    wire op_is_posit_to_float = (op == POSIT_TO_FLOAT);
    wire op_is_ops = (op == ADD | op == SUB | op == MUL | op == DIV);

    wire [N-1:0] p1, p2, pout;
    
    assign p1 = in1[N-1:0];
    assign p2 = in2[N-1:0];


    ppu_core_ops #(
        .N(N),
        .ES(ES)
    ) ppu_core_ops_inst (
        .p1(p1),
        .p2(p2),
        .op(op),
        .pout(pout)
    );

    wire float_sign;
    wire [FLOAT_EXP_SIZE_F`F-1:0] float_exp;
    wire [FLOAT_MANT_SIZE_F`F-1:0] float_frac;

    float_to_pif #(
        .FSIZE(FSIZE)
    ) float_to_pif_inst (
        .bits(float),
        .sign(float_sign),
        .exp(float_exp),
        .frac(float_frac)
    );


endmodule
