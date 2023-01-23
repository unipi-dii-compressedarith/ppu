module compute_rouding
  import ppu_pkg::*;
#(
  parameter N  = -1,
  parameter ES = -1
) (
  input  [ MANT_LEN_BITS-1:0] frac_len_i,
  input  [FRAC_FULL_SIZE-1:0] frac_full_i,
  input  [         (S+2)-1:0] frac_len_diff_i,
  input  [        K_BITS-1:0] k_i,
`ifndef NO_ES_FIELD
  input  [            ES-1:0] exp_i,
`endif
  input                       frac_truncated_i,
  output                      round_bit_o,
  output                      sticky_bit_o
);

  wire [(3*MANT_SIZE+2)-1:0] _tmp0, _tmp1, _tmp2, _tmp3;

  assign _tmp0 = (1 << (frac_len_diff_i - 1));
  assign _tmp1 = frac_full_i & _tmp0;

`ifndef NO_ES_FIELD
  assign round_bit_o = $signed(
    frac_len_i
  ) >= 0 ? _tmp1 != 0 : $signed(
    k_i
  ) == N - 2 - ES ? exp_i > 0 && $unsigned(
    frac_full_i
  ) > 0 : $signed(
    k_i
  ) == -(N - 2) ? /*$signed*/(                /* no longer signed. bug fixed 
                                                  Fri Apr  1 14:56:46 CEST 2022 
                                                  after P<16,1> 0x73 * 0xa4 
                                                  resulted in 0x1 rather than 
                                                  the correct result 0x2 */
    exp_i
  ) > 0 : 1'b0;
`else
  assign round_bit_o = $signed(frac_len_i) >= 0 ? (_tmp1 != 0) : 1'b0;
`endif


  assign _tmp2 = ((1 << (frac_len_diff_i - 1)) - 1);
  assign _tmp3 = frac_full_i & _tmp2;

  assign sticky_bit_o = $signed(frac_len_i) >= 0 ? (_tmp3 != 0) || frac_truncated_i : 1'b0;

endmodule: compute_rouding
