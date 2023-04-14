/// Posit processing unit operations
module ops 
  import ppu_pkg::*;
#(
  parameter N = -1
) (
  input logic             clk_i,
  input logic             rst_i,
  input operation_e       op_i,
  input fir_t             fir1_i,
  input fir_t             fir2_i,
  input fir_t             fir3_i,
  output ops_out_meta_t   ops_result_o
);

  
  wire [FRAC_FULL_SIZE-1:0] frac_out;

  logic sign_out;
  exponent_t te_out;
  wire [FRAC_FULL_SIZE-1:0] frac_full;

  wire frac_truncated;

  core_op #(
    .TE_BITS          (TE_BITS),
    .MANT_SIZE        (MANT_SIZE),
    .FRAC_FULL_SIZE   (FRAC_FULL_SIZE)
  ) core_op_inst (
    .clk_i            (clk_i),
    .rst_i            (rst_i),
    .op_i             (op_i),
    
    .fir1_i           (fir1_i),
    .fir2_i           (fir2_i),
    .fir3_i           (fir3_i),
    
    .sign_o           (sign_out),
    .te_o             (te_out),
    .frac_o           (frac_out),
    .frac_truncated_o (frac_truncated)
  );




  /*
  sign_decisor sign_decisor (
    .clk_i            (clk_i),
    .rst_i            (rst_i),
    .sign1_i          (fir1_i.sign),
    .sign2_i          (fir2_i.sign),
    .sign3_i          (fir3_i.sign),
    .op_i             (op_i),
    .sign_o           (sign_out)
  );
  */
  
  assign ops_result_o.long_fir = {sign_out, te_out, frac_out};
  assign ops_result_o.frac_truncated = frac_truncated;

endmodule: ops
