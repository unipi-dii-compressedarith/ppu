module pack_fields 
  import ppu_pkg::*;
#(
  parameter N  = -1,
  parameter ES = -1
) (
  input [FRAC_FULL_SIZE-1:0] frac_full_i,
  input [       TE_BITS-1:0] total_exp_i,
  input                      frac_truncated_i, // new flag

  output [   K_BITS-1:0] k_o,
`ifndef NO_ES_FIELD
  output [       ES-1:0] next_exp_o,
`endif
  output [MANT_SIZE-1:0] frac_o,

  // flags
  output round_bit,
  output sticky_bit,
  output k_is_oob,
  output non_zero_frac_field_size
);

  wire [K_BITS-1:0] k_unpacked;

`ifndef NO_ES_FIELD
  wire [ES-1:0] exp_unpacked;
`endif

  unpack_exponent #(
    .N          (N),
    .ES         (ES)
  ) unpack_exponent_inst (
    .total_exp_i(total_exp_i),
    .k_o        (k_unpacked)
`ifndef NO_ES_FIELD,
    .exp_o      (exp_unpacked)
`endif
  );


  wire [K_BITS-1:0] regime_k;
  assign regime_k = ($signed(
      k_unpacked
  ) <= (N - 2) && $signed(
      k_unpacked
  ) >= -(N - 2)) ? $signed(
      k_unpacked
  ) : ($signed(
      k_unpacked
  ) >= 0 ? N - 2 : -(N - 2));

  assign k_is_oob = k_unpacked != regime_k;

  wire [REG_LEN_BITS-1:0] reg_len;
  assign reg_len = $signed(regime_k) >= 0 ? regime_k + 2 : -$signed(regime_k) + 1;


  wire [MANT_LEN_BITS-1:0] frac_len;  // fix size
  assign frac_len = N - 1 - ES - reg_len;

`ifndef NO_ES_FIELD
  wire [(ES+1)-1:0] es_actual_len;  // ES + 1 because it may potentially be negative.
  assign es_actual_len = min(ES, N - 1 - reg_len);


  wire [ES-1:0] exp1;
  assign exp1 = exp_unpacked >> max(0, ES - es_actual_len);
`endif


  wire [(S+2)-1:0] frac_len_diff;
  assign frac_len_diff = FRAC_FULL_SIZE - $signed(frac_len);


  compute_rouding #(
    .N                (N),
    .ES               (ES)
  ) compute_rouding_inst (
    .frac_len_i       (frac_len),
    .frac_full_i      (frac_full_i),
    .frac_len_diff_i  (frac_len_diff),
    .k_i              (regime_k),
`ifndef NO_ES_FIELD
    .exp_i            (exp_unpacked),
`endif
    .frac_truncated_i (frac_truncated_i),
    .round_bit_o      (round_bit),
    .sticky_bit_o     (sticky_bit)
  );

  assign k_o = regime_k;  // prev. k_unpacked which is wrong;

`ifndef NO_ES_FIELD
  wire [ES-1:0] exp2;
  assign exp2 = exp1 << (ES - es_actual_len);
`endif

  assign frac_o = frac_full_i >> frac_len_diff;

  assign non_zero_frac_field_size = $signed(frac_len) >= 0;

`ifndef NO_ES_FIELD
  assign next_exp_o = exp2;
`endif

endmodule: pack_fields
