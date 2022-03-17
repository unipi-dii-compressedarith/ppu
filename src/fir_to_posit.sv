module fir_to_posit #(
    parameter N = 4,
    parameter ES = 0,
    parameter FIR_TOTAL_SIZE = 43
) (
    input [(
                FIR_TOTAL_SIZE      // fir
                + 1                 // frac_lsb_cut_off
            )-1:0] ops_in,
    output [N-1:0] posit
);

    wire [FIR_TOTAL_SIZE-1:0] fir;
    wire frac_lsb_cut_off;  // flag
    assign {fir, frac_lsb_cut_off} = ops_in;

    wire sign;
    wire [TE_SIZE-1:0] te;
    wire [FRAC_FULL_SIZE-1:0] frac_full;
    assign {sign, te, frac_full} = fir;


    wire [MANT_SIZE-1:0] frac;
    wire [K_SIZE-1:0] k;
`ifndef NO_ES_FIELD
    wire [ES-1:0] next_exp;
`endif

    pack_fields #(
        .N (N),
        .ES(ES)
    ) pack_fields_inst (
        .frac_full(frac_full), // the whole mantissa w/o the leading 1. (let's call it `frac_full` to distinguish it from `frac`)
        .total_exp(te),
        .frac_lsb_cut_off(frac_lsb_cut_off),

        .k(k),
`ifndef NO_ES_FIELD
        .next_exp(next_exp),
`endif
        .frac(frac), // the fractional part of the posit that actually fits in its (remaining) field. it's the most significant bits of `frac_full`.

        .round_bit(round_bit),
        .sticky_bit(sticky_bit),
        .k_is_oob(k_is_oob),
        .non_zero_frac_field_size(non_zero_frac_field_size)
    );


    wire [N-1:0] posit_encoded;
    posit_encoder #(
        .N (N),
        .ES(ES)
    ) posit_encoder_inst (
        .sign(1'b0),
        .k(k),
`ifndef NO_ES_FIELD
        .exp(next_exp),
`endif
        .frac(frac),
        .posit(posit_encoded)
    );


    wire [N-1:0] posit_pre_sign;

    round_posit #(
        .N(N)
    ) round_posit_inst (
        .posit(posit_encoded),
        .round_bit(round_bit),
        .sticky_bit(sticky_bit),
        .k_is_oob(k_is_oob),
        .non_zero_frac_field_size(non_zero_frac_field_size),

        .posit_rounded(posit_pre_sign)
    );


    set_sign #(
        .N(N)
    ) set_sign_inst (
        .posit_in(posit_pre_sign),
        .sign(sign),
        .posit_out(posit)
    );


endmodule
