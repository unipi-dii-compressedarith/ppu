module extraction
  import ppu_pkg::*;
#(
  parameter N = -1
) (
  /// Input conditioning
  input  posit_t            p1_i,
  input  posit_t            p2_i,
  input  posit_t            p3_i,
  input  operation_e        op_i,
  /// posit to fir
  output fir_t              fir1_o,
  output fir_t              fir2_o,
  output fir_t              fir3_o,

  output posit_special_t    p_special_o // `pout_special_or_trivial` + `is_special_or_trivial` tag
);

  
  posit_t p1_cond, p2_cond, p3_cond;

  input_conditioning #(
    .N          (N)
  ) input_conditioning (
    .p1_i       (p1_i),
    .p2_i       (p2_i),
    .p3_i       (p3_i),
    .op_i       (op_i),
    .p1_o       (p1_cond),
    .p2_o       (p2_cond),
    .p3_o       (p3_cond),
    .p_special_o(p_special_o)
  );

  posit_to_fir #(
    .N          (N),
    .ES         (ES)
  ) posit_to_fir1 (
    .p_cond_i   (p1_cond),
    .fir_o      (fir1_o)
  );

  wire [N-1:0] posit_in_posit_to_fir2;
  assign posit_in_posit_to_fir2 =
`ifdef FLOAT_TO_POSIT
    (op_st0 == POSIT_TO_FLOAT) ? p2_i :
`endif
    p2_cond;


  posit_to_fir #(
    .N          (N),
    .ES         (ES)
  ) posit_to_fir2 (
    .p_cond_i   (posit_in_posit_to_fir2),
    .fir_o      (fir2_o)
  );


  posit_to_fir #(
    .N          (N),
    .ES         (ES)
  ) posit_to_fir3 (
    .p_cond_i   (p3_cond),
    .fir_o      (fir3_o)
  );


endmodule: extraction
