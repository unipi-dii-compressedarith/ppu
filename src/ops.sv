/// Posit processing unit operations
module ops 
  import ppu_pkg::*;
#(
  parameter N = -1
) (
  input                   clk_i,
  input                   rst_i,
  input operation_e       op_i,
  input fir_t             fir1_i,
  input fir_t             fir2_i,
  input fir_t             fir3_i,

  output ops_out_meta_t   ops_result_o

  // output [(
  //             (1 + TE_BITS + FRAC_FULL_SIZE)  // fir_ops_out
  //             + 1                             // frac_truncated
  //         )-1:0]                ops_result_o
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

  assign {sign1, te1, mant1} = fir1_i;
  assign {sign2, te2, mant2} = fir2_i;

  core_op #(
    .TE_BITS          (TE_BITS),
    .MANT_SIZE        (MANT_SIZE),
    .FRAC_FULL_SIZE   (FRAC_FULL_SIZE)
  ) core_op_inst (
    .clk_i            (clk_i),
    .rst_i            (rst_i),
    .op_i             (op_i),
    // .sign1_i          (sign1),
    // .sign2_i          (sign2),
    // .te1_i            (te1),
    // .te2_i            (te2),
    // .mant1_i          (mant1),
    // .mant2_i          (mant2),
    .fir1_i           (fir1_i),
    .fir2_i           (fir2_i),
    .fir3_i           (fir3_i),

    .te_o             (te_out),
    .frac_o           (frac_out),
    .frac_truncated_o (frac_truncated)
  );

  sign_decisor sign_decisor (
    .clk_i            (clk_i),
    .rst_i            (rst_i),
    .sign1_i          (fir1_i.sign),
    .sign2_i          (fir2_i.sign),
    .op_i             (op_i),
    .sign_o           (sign_out)
  );

  assign fir_ops_out = {sign_out, te_out, frac_out};

  
  assign ops_result_o.long_fir = fir_ops_out;
  assign ops_result_o.frac_truncated = frac_truncated;

endmodule: ops
