`ifdef FLOAT_TO_POSIT
module pif_to_float #(
        parameter N = 10,
        parameter ES = 1,
        parameter FSIZE = 54
    )(
        input  [PIF_SIZE-1:0]   pif,
        output [FSIZE-1:0]      float
    );

    parameter FLOAT_EXP_SIZE = FLOAT_EXP_SIZE_F`F;
    parameter FLOAT_MANT_SIZE = FLOAT_MANT_SIZE_F`F;



    wire posit_sign;
    wire signed [TE_SIZE-1:0] posit_te;
    wire [MANT_SIZE-1:0] posit_frac;

    assign {posit_sign, posit_te, posit_frac} = pif;

    

    wire float_sign;
    wire signed [FLOAT_EXP_SIZE-1:0] float_exp;
    wire [FLOAT_MANT_SIZE-1:0] float_frac;

    assign float_sign = posit_sign;
    
    sign_extend #(
        .POSIT_TOTAL_EXPONENT_SIZE(TE_SIZE),
        .FLOAT_EXPONENT_SIZE(FLOAT_EXP_SIZE)
    ) sign_extend_inst (
        .posit_total_exponent(posit_te),
        .float_exponent(float_exp)
    );      


    assign float_frac = posit_frac << (FLOAT_MANT_SIZE - MANT_SIZE + 1);

    float_encoder #(
        .FSIZE(FSIZE)
    ) float_encoder_inst (
        .sign(float_sign),
        .exp(float_exp),
        .frac(float_frac),
        .bits(float)
    );


endmodule
`endif