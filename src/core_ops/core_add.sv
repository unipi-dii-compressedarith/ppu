module core_add 
  import ppu_pkg::*;
#(
  parameter TE_BITS = -1,
  parameter MANT_ADD_RESULT_SIZE = -1
) (
  input  [(MANT_ADD_RESULT_SIZE)-1:0] mant_i,
  input  exponent_t                   te_diff_i,
  output [(MANT_ADD_RESULT_SIZE)-1:0] new_mant_o,
  output exponent_t                   new_te_diff_o,
  output                              frac_truncated_o
);

  wire mant_carry;
  assign mant_carry = mant_i[MANT_ADD_RESULT_SIZE-1];

  assign new_mant_o = mant_carry == 1'b1 ? mant_i >> 1 : mant_i;
  assign new_te_diff_o = mant_carry == 1'b1 ? te_diff_i + 1 : te_diff_i;

  assign frac_truncated_o = mant_carry && (mant_i & 1);

endmodule: core_add
