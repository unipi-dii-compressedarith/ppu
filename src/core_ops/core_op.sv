module core_op 
  import ppu_pkg::*;
#(
  parameter TE_BITS = -1,
  parameter MANT_SIZE = -1,
  parameter FRAC_FULL_SIZE = -1
) (
  input                         clk_i,
  input                         rst_i,
  input operation_e             op_i,
  input                         sign1_i,
  input                         sign2_i,
  input  [         TE_BITS-1:0] te1_i,
  input  [         TE_BITS-1:0] te2_i,
  input  [       MANT_SIZE-1:0] mant1_i,
  input  [       MANT_SIZE-1:0] mant2_i,
  output [         TE_BITS-1:0] te_o,
  output [(FRAC_FULL_SIZE)-1:0] frac_o,
  output                        frac_truncated_o
);

  wire [(MANT_ADD_RESULT_SIZE)-1:0] mant_out_add_sub;
  wire [(MANT_MUL_RESULT_SIZE)-1:0] mant_out_mul;
  wire [(MANT_DIV_RESULT_SIZE)-1:0] mant_out_div;


  wire [TE_BITS-1:0] te_out_add_sub, te_out_mul, te_out_div;
  wire frac_truncated_add_sub, frac_truncated_mul, frac_truncated_div;

  core_add_sub #(
    .TE_BITS                (TE_BITS),
    .MANT_SIZE              (MANT_SIZE),
    .MANT_ADD_RESULT_SIZE   (MANT_ADD_RESULT_SIZE)
  ) core_add_sub_inst (
    .clk_i                  (clk_i),
    .rst_i                  (rst_i),
    .te1_i                  (te1_i),
    .te2_i                  (te2_i),
    .mant1_i                (mant1_i),
    .mant2_i                (mant2_i),
    .have_opposite_sign_i   (sign1_i ^ sign2_i),
    .mant_o                 (mant_out_add_sub),
    .te_o                   (te_out_add_sub),
    .frac_truncated_o       (frac_truncated_add_sub)
  );

  core_mul #(
    .TE_BITS                (TE_BITS),
    .MANT_SIZE              (MANT_SIZE),
    .MANT_MUL_RESULT_SIZE   (MANT_MUL_RESULT_SIZE)
  ) core_mul_inst (
    .clk_i                  (clk_i),
    .rst_i                  (rst_i),
    .te1_i                  (te1_i),
    .te2_i                  (te2_i),
    .mant1_i                (mant1_i),
    .mant2_i                (mant2_i),
    .mant_o                 (mant_out_mul),
    .te_o                   (te_out_mul),
    .frac_truncated_o       (frac_truncated_mul)
  );

  core_div #(
    .TE_BITS                (TE_BITS),
    .MANT_SIZE              (MANT_SIZE),
    .MANT_DIV_RESULT_SIZE   (MANT_DIV_RESULT_SIZE)
  ) core_div_inst (
    .clk_i                  (clk_i),
    .rst_i                  (rst_i),
    .te1_i                  (te1_i),
    .te2_i                  (te2_i),
    .mant1_i                (mant1_i),
    .mant2_i                (mant2_i),
    .mant_o                 (mant_out_div),
    .te_o                   (te_out_div),
    .frac_truncated_o       (frac_truncated_div)
  );


  wire [(FRAC_FULL_SIZE)-1:0] mant_out_core_op;
  assign mant_out_core_op = (op_i == ADD || op_i == SUB)
    ? mant_out_add_sub << (FRAC_FULL_SIZE - MANT_ADD_RESULT_SIZE) : op_i == MUL
    ? mant_out_mul << (FRAC_FULL_SIZE - MANT_MUL_RESULT_SIZE) : /* op_i == DIV */
      mant_out_div;


  // chopping off the two MSB representing the
  // non-fractional components i.e. ones and tens.
  assign frac_o = op_i == DIV
    ? mant_out_core_op : /* ADD, SUB, and MUL */
      mant_out_core_op << 2;

  assign te_o = (op_i == ADD || op_i == SUB)
    ? te_out_add_sub : op_i == MUL
    ? te_out_mul : /* op_i == DIV */
      te_out_div;

  assign frac_truncated_o = op_i == MUL
    ? frac_truncated_mul : op_i == DIV
    ? frac_truncated_div : /* op_i == ADD || op_i == SUB */
      frac_truncated_add_sub;

endmodule: core_op
