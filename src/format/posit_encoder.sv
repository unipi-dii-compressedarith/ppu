module posit_encoder 
  import ppu_pkg::*;
#(
    parameter N = 4,
    parameter ES = 1
)(
    input                           is_zero_i,
    input                           is_nar_i,
    input                           sign,
    input [K_SIZE-1:0]              k,
`ifndef NO_ES_FIELD
    input [ES-1:0]                  exp,
`endif
    input [MANT_SIZE-1:0]           frac,
    output [N-1:0]                  posit
  );

  wire [REG_LEN_SIZE-1:0] reg_len;
  assign reg_len = $signed(k) >= 0 ? k + 2 : -$signed(k) + 1;

  wire [N-1:0] bits_assembled;

  wire [N:0] regime_bits; // 1 bit longer than it could regularly fit in.

  assign regime_bits = is_negative(k) ? 1 : (shl(1, (k + 1)) - 1) << 1;


`ifndef NO_ES_FIELD
`else
  wire exp = 0;
`endif

  assign bits_assembled = (
      shl(sign, N-1)
    + shl(regime_bits, N - 1 - reg_len)
`ifndef NO_ES_FIELD
    + shl(exp, N - 1 - reg_len - ES)
`endif
    + frac
  );

  assign posit =
    sign == 0
    ? bits_assembled : c2(bits_assembled & ~(1 << (N - 1)));

  /*
  ~(1'b1 << (N-1)) === {1'b0, {N-1{1'b1}}}
  */

endmodule: posit_encoder
