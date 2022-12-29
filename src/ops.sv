/// Posit processing unit operations
module ops 
  import ppu_pkg::*;
#(
  parameter N = -1
) (
  input                           clk_i,
  input                           rst_i,
  input ppu_pkg::operation_e      op_i,
  input [FIR_SIZE-1:0]            fir1,
  input [FIR_SIZE-1:0]            fir2,

  output [(
              (1 + TE_BITS + FRAC_FULL_SIZE)  // fir_ops_out
              + 1                             // frac_truncated
          )-1:0]                ops_result_o
);

  wire sign1, sign2;
  wire [TE_BITS-1:0] te1, te2;
  wire [MANT_SIZE-1:0] mant1, mant2;
  wire [FRAC_FULL_SIZE-1:0] frac_out;


  wire sign_out;
  wire [TE_BITS-1:0] te_out;
  wire [FRAC_FULL_SIZE-1:0] frac_full;

  wire [(1 + TE_BITS + FRAC_FULL_SIZE)-1:0] fir_ops_out;
  wire frac_truncated;

  assign {sign1, te1, mant1} = fir1;
  assign {sign2, te2, mant2} = fir2;

  core_op #(
    .N(N)
  ) core_op_inst (
    .clk(clk),
    .rst(rst),
    .op_i(op_i),
    .sign1(sign1),
    .sign2(sign2),
    .te1(te1),
    .te2(te2),
    .mant1(mant1),
    .mant2(mant2),
    .te_out_core_op(te_out),
    .frac_out_core_op(frac_out),
    .frac_truncated(frac_truncated)
  );

  sign_decisor #() sign_decisor (
    .clk(clk),
    .rst(rst),
    .sign1(sign1),
    .sign2(sign2),
    .op(op_i),
    .sign(sign_out)
  );

  assign fir_ops_out = {sign_out, te_out, frac_out};

  assign ops_result_o = {fir_ops_out, frac_truncated};

endmodule: ops
