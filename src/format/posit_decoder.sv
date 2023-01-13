module posit_decoder 
  import ppu_pkg::*;
#(
  parameter N  = -1,  // dummy
  parameter ES = -1   // dummy
) (
  input posit_t   bits_i,
  output fir_t    fir_o
);

  wire                    _reg_s;  // unused, only to satisfy the linter
  wire [REG_LEN_BITS-1:0] _reg_len;  // unused, only to satisfy the linter

  wire [K_BITS-1:0] k;
`ifndef NO_ES_FIELD
  wire [ES-1:0] exp;
`endif

  wire sign;
  wire [TE_BITS-1:0] total_exponent;
  wire [MANT_SIZE-1:0] mant;

  posit_unpack #(
    .N          (N),
    .ES         (ES)
  ) posit_unpack_inst (
    .bits_i     (bits_i),
    .sign_o     (sign),
    .reg_s_o    (_reg_s),
    .reg_len_o  (_reg_len),
    .k_o        (k),
`ifndef NO_ES_FIELD
    .exp_o      (exp),
`endif
    .mant_o     (mant)
  );

  total_exponent #(
    .N          (N),
    .ES         (ES)
  ) total_exponent_inst (
    .k_i        (k),
`ifndef NO_ES_FIELD
    .exp_i      (exp),
`endif
    .total_exp_o(total_exponent)
  );

  assign fir_o.sign = sign;
  assign fir_o.total_exponent = total_exponent;
  assign fir_o.mant = mant;

endmodule: posit_decoder
