module core_fma_accumulator
  import ppu_pkg::*;
#(
  /// Posit size
  parameter N                                 = -1,
  /// Input FIR sizes
  parameter TE_BITS                           = -1,
  parameter MANT_SIZE                         = -1,
  parameter FRAC_FULL_SIZE                    = -1,
  /// Fixed point format
  parameter FX_M                              = `FX_M,
  parameter FX_B                              = `FX_B,
  /// output FIR sizes
  parameter FIR_TE_SIZE                       = -1,
  parameter FIR_FRAC_SIZE                     = -1
)(
  input logic                                   clk_i,
  input logic                                   rst_i,
  input operation_e                             op_i,
  
  input [(1+TE_BITS+MANT_MUL_RESULT_SIZE)-1:0]  fir1_i,
  input fir_t                                   fir2_i,

  output logic [(1+FIR_TE_SIZE+
                FIR_FRAC_SIZE)-1:0]             fir_fma,
  output logic [(FX_B)-1:0]                     fixed_o
  // output logic                               frac_truncated_o
);

  operation_e op_st1;
  always_ff @(posedge clk_i) op_st1 <= op_i;

  logic start_fma;
  assign start_fma = (op_i === FMADD) && (op_st1 !== FMADD);

  logic fma_valid;
  assign fma_valid = op_i !== FMADD && op_st1 === FMADD ? 1'b1 : 'b0;

  
  logic [(FX_B)-1:0] fir1_fixed, fir2_fixed;
  fir_to_fixed #(
    .N              (2*N-3),   // TODO: Change this parameter to work with other values of N as well (ok with N=16)
    .FIR_TE_SIZE    (TE_BITS),
    .FIR_FRAC_SIZE  (MANT_MUL_RESULT_SIZE),
    .FX_M           (FX_M),
    .FX_B           (FX_B)
  ) fir_to_fixed_1_mul (
    .fir_i          (fir1_i),
    .fixed_o        (fir1_fixed)
  );


  fir_to_fixed #(
    .N              (N),
    .FIR_TE_SIZE    ($bits(fir2_i.total_exponent)),
    .FIR_FRAC_SIZE  ($bits(fir2_i.mant)),
    .FX_M           (FX_M),
    .FX_B           (FX_B)
  ) fir_to_fixed_2_fir3 (
    .fir_i          (fir2_i),
    .fixed_o        (fir2_fixed)
  );
  


  logic [(FX_B)-1:0] acc;
  accumulator #(
    .FIXED_SIZE   ($bits(fir1_fixed))
  ) accumulator_inst (
    .clk_i        (clk_i),
    .rst_i        (rst_i),
    .start_i      (start_fma),
    .init_value_i (fir2_fixed),
    .fixed_i      (fir1_fixed),
    .fixed_o      (acc)
  );


  fixed_to_fir #(
    .N              (N),
    .FIR_TE_SIZE    (TE_BITS),
    .FIR_FRAC_SIZE  (FRAC_FULL_SIZE),
    .FX_M           (FX_M),
    .FX_B           (FX_B)
  ) fixed_to_fir_acc (
    .fixed_i        (acc),
    .fir_o          (fir_fma)
  );

  
  
  //assign fixed_o = op_i !== FMADD && op_st1 === FMADD ? acc : 'b0;
  assign fixed_o = acc;

endmodule: core_fma_accumulator
