module pif_to_posit #(
        parameter N = 4,
        parameter ES = 0
    )(
        
        input [TE_SIZE-1:0] te,
        input [FRAC_FULL_SIZE-1:0] frac_full,    
        input frac_lsb_cut_off, // flag
        output [N-1:0] posit
    );


    wire [MANT_SIZE-1:0] frac;
    wire [K_SIZE-1:0] k;
    
    shift_fields #(
        .N(N),
        .ES(ES)
    ) shift_fields_inst (
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
    posit_encode #(
        .N(N),
        .ES(ES)
    ) posit_encode_inst (
        .sign(1'b0),
        .k(k),
`ifndef NO_ES_FIELD
        .exp(next_exp),
`endif
        .frac(frac),
        .posit(posit_encoded)
    );


    round_posit #(
        .N(N)
    ) round_posit_inst (
        .posit(posit_encoded),
        .round_bit(round_bit),
        .sticky_bit(sticky_bit),
        .k_is_oob(k_is_oob),
        .non_zero_frac_field_size(non_zero_frac_field_size),
        
        .posit_rounded(posit)
    );


endmodule