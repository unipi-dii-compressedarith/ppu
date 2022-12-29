module compute_rouding
  import ppu_pkg::*;
#(
  parameter N  = 5,
  parameter ES = 0
) (
  input  [ MANT_LEN_BITS-1:0] frac_len,
  input  [FRAC_FULL_SIZE-1:0] frac_full,
  input  [         (S+2)-1:0] frac_len_diff,
  input  [        K_BITS-1:0] k,
`ifndef NO_ES_FIELD
  input  [            ES-1:0] exp,
`endif
  input                       frac_truncated,
  output                      round_bit,
  output                      sticky_bit
);

  wire [(3*MANT_SIZE+2)-1:0] _tmp0, _tmp1, _tmp2, _tmp3;

  assign _tmp0 = (1 << (frac_len_diff - 1));
  assign _tmp1 = frac_full & _tmp0;

`ifndef NO_ES_FIELD
  assign round_bit = $signed(
    frac_len
  ) >= 0 ? _tmp1 != 0 : $signed(
    k
  ) == N - 2 - ES ? exp > 0 && $unsigned(
    frac_full
  ) > 0 : $signed(
    k
  ) == -(N - 2) ? /*$signed*/(                /* no longer signed. bug fixed 
                                                  Fri Apr  1 14:56:46 CEST 2022 
                                                  after P<16,1> 0x73 * 0xa4 
                                                  resulted in 0x1 rather than 
                                                  the correct result 0x2 */
    exp
  ) > 0 : 1'b0;
`else
  assign round_bit = $signed(frac_len) >= 0 ? (_tmp1 != 0) : 1'b0;
`endif


  assign _tmp2 = ((1 << (frac_len_diff - 1)) - 1);
  assign _tmp3 = frac_full & _tmp2;

  assign sticky_bit = $signed(frac_len) >= 0 ? (_tmp3 != 0) || frac_truncated : 1'b0;

endmodule: compute_rouding
