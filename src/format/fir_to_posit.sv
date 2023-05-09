module fir_to_posit 
  import ppu_pkg::*;
#(
  parameter N = -1,
  parameter ES = -1,
  parameter FIR_TOTAL_SIZE = -1
) (
  input ops_out_meta_t  ops_result_i, // TODO: fix frac_full. from `1.fff` to `.fff`.   `1.` must be appended here.
  output posit_t        posit_o
);

  long_fir_t fir;
  assign fir = ops_result_i.long_fir;
  
  logic frac_truncated;  // flag
  assign frac_truncated = ops_result_i.frac_truncated;

  logic sign;
  exponent_t te;
  wire [FRAC_FULL_SIZE-1:0] frac_full;
  assign {sign, te, frac_full} = fir;


  wire [MANT_SIZE-1:0] frac;
  wire [K_BITS-1:0] k;
`ifndef NO_ES_FIELD
  wire [ES-1:0] next_exp;
`endif

  pack_fields #(
    .N                (N),
    .ES               (ES)
  ) pack_fields_inst (
    .frac_full_i      (frac_full), // the whole mantissa w/o the leading 1. (let's call it `frac_full` to distinguish it from `frac`)
    .total_exp_i      (te),
    .frac_truncated_i (frac_truncated),

    .k_o              (k),
`ifndef NO_ES_FIELD
    .next_exp_o       (next_exp),
`endif
    .frac_o           (frac), // the fractional part of the posit that actually fits in its (remaining) field. it's the most significant bits of `frac_full`.

    .round_bit        (round_bit),
    .sticky_bit       (sticky_bit),
    .k_is_oob         (k_is_oob),
    .non_zero_frac_field_size(non_zero_frac_field_size)
  );


  wire [N-1:0] posit_encoded;
  posit_encoder #(
    .N              (N),
    .ES             (ES)
) posit_encoder_inst (
    .is_zero_i      (),
    .is_nar_i       (),
    .sign           (1'b0),
    .k              (k),
`ifndef NO_ES_FIELD
    .exp            (next_exp),
`endif
    .frac           (frac),
    .posit          (posit_encoded)
  );


  wire [N-1:0] posit_pre_sign;

  round_posit #(
    .N              (N)
  ) round_posit_inst (
    .posit          (posit_encoded),
    .round_bit      (round_bit),
    .sticky_bit     (sticky_bit),
    .k_is_oob       (k_is_oob),
    .non_zero_frac_field_size(non_zero_frac_field_size),
    .posit_rounded  (posit_pre_sign)
  );


  set_sign #(
    .N              (N)
  ) set_sign_inst (
    .posit_in       (posit_pre_sign),
    .sign           (sign),
    .posit_out      (posit_o)
  );

endmodule: fir_to_posit
