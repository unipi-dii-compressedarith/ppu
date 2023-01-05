module core_op 
  import ppu_pkg::*;
#(
  parameter N = `N
) (
  input                         clk,
  input                         rst,
  input operation_e             op_i,
  input                         sign1,
  input                         sign2,
  input  [         TE_BITS-1:0] te1,
  input  [         TE_BITS-1:0] te2,
  input  [       MANT_SIZE-1:0] mant1,
  input  [       MANT_SIZE-1:0] mant2,
  output [         TE_BITS-1:0] te_out_core_op,
  output [(FRAC_FULL_SIZE)-1:0] frac_out_core_op,
  output                        frac_truncated
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
    .clk                    (clk),
    .rst                    (rst),
    .te1_in                 (te1),
    .te2_in                 (te2),
    .mant1_in               (mant1),
    .mant2_in               (mant2),
    .have_opposite_sign     (sign1 ^ sign2),
    .mant_out               (mant_out_add_sub),
    .te_out                 (te_out_add_sub),
    .frac_truncated         (frac_truncated_add_sub)
  );

  core_mul #(
    .TE_BITS                (TE_BITS),
    .MANT_SIZE              (MANT_SIZE),
    .MANT_MUL_RESULT_SIZE   (MANT_MUL_RESULT_SIZE)
  ) core_mul_inst (
    .clk                    (clk),
    .rst                    (rst),
    .te1                    (te1),
    .te2                    (te2),
    .mant1                  (mant1),
    .mant2                  (mant2),
    .mant_out               (mant_out_mul),
    .te_out                 (te_out_mul),
    .frac_truncated         (frac_truncated_mul)
  );

  core_div #(
    .TE_BITS                (TE_BITS),
    .MANT_SIZE              (MANT_SIZE),
    .MANT_DIV_RESULT_SIZE   (MANT_DIV_RESULT_SIZE)
  ) core_div_inst (
    .clk                    (clk),
    .rst                    (rst),
    .te1                    (te1),
    .te2                    (te2),
    .mant1                  (mant1),
    .mant2                  (mant2),
    .mant_out               (mant_out_div),
    .te_out                 (te_out_div),
    .frac_truncated         (frac_truncated_div)
  );


  wire [(FRAC_FULL_SIZE)-1:0] mant_out_core_op;
  assign mant_out_core_op = (op_i == ADD || op_i == SUB)
    ? mant_out_add_sub << (FRAC_FULL_SIZE - MANT_ADD_RESULT_SIZE) : op_i == MUL
    ? mant_out_mul << (FRAC_FULL_SIZE - MANT_MUL_RESULT_SIZE) : /* op_i == DIV */
      mant_out_div;


  // chopping off the two MSB representing the
  // non-fractional components i.e. ones and tens.
  assign frac_out_core_op = op_i == DIV
    ? mant_out_core_op : /* ADD, SUB, and MUL */
      mant_out_core_op << 2;

  assign te_out_core_op = (op_i == ADD || op_i == SUB)
    ? te_out_add_sub : op_i == MUL
    ? te_out_mul : /* op_i == DIV */
      te_out_div;

  assign frac_truncated = op_i == MUL
    ? frac_truncated_mul : op_i == DIV
    ? frac_truncated_div : /* op_i == ADD || op_i == SUB */
      frac_truncated_add_sub;

endmodule: core_op
