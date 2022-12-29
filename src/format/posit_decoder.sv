module posit_decoder 
  import ppu_pkg::*;
#(
  parameter N  = 4,  // dummy
  parameter ES = 0   // dummy
) (
  input  [        N-1:0] bits,
  /////////////
  output                 sign,
  output [  TE_BITS-1:0] te,
  output [MANT_SIZE-1:0] mant
);

  wire                    _reg_s;  // unused, only to satisfy the linter
  wire [REG_LEN_BITS-1:0] _reg_len;  // unused, only to satisfy the linter

  wire [K_BITS-1:0] k;
`ifndef NO_ES_FIELD
  wire [ES-1:0] exp;
`endif

  posit_unpack #(
    .N (N),
    .ES(ES)
  ) posit_unpack_inst (
    .bits(bits),
    .sign   (sign),
    .reg_s  (_reg_s),
    .reg_len(_reg_len),
    .k      (k),
`ifndef NO_ES_FIELD
    .exp    (exp),
`endif
    .mant   (mant)
  );

  total_exponent #(
    .N (N),
    .ES(ES)
) total_exponent_inst (
    .k(k),
`ifndef NO_ES_FIELD
    .exp(exp),
`endif
    .total_exp(te)
  );


endmodule: posit_decoder
