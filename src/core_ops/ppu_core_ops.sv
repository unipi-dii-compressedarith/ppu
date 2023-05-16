module ppu_core_ops 
  import ppu_pkg::*;
#(
  parameter N = -1,
  parameter ES = -1
`ifdef FLOAT_TO_POSIT
  ,parameter FSIZE = -1
`endif
)(
  input                                         clk_i,
  input                                         rst_i,
  input   ppu_pkg::posit_t                      p1_i,
  input   ppu_pkg::posit_t                      p2_i,
  input   ppu_pkg::posit_t                      p3_i,
  input   ppu_pkg::operation_e                  op_i,
  output  ppu_pkg::operation_e                  op_o,
  input                                         stall_i,
`ifdef FLOAT_TO_POSIT
  input       [(1+TE_BITS+FRAC_FULL_SIZE)-1:0]  float_fir_i,
  output     ppu_pkg::fir_t                     posit_fir_o,
`endif
  output  ppu_pkg::posit_t                      pout_o,
  ///
  output [`FX_B-1:0]                            fixed_o
);

  fir_t fir1, fir2, fir3;
  posit_special_t p_special;

  extraction #(
    .N            (N)
  ) extraction_i (
    .p1_i         (p1_i),
    .p2_i         (p2_i),
    .p3_i         (p3_i),
    .op_i         (op_i),

    .fir1_o       (fir1),
    .fir2_o       (fir2),
    .fir3_o       (fir3),

    .p_special_o  (p_special)
  );

    

`ifdef FLOAT_TO_POSIT
  assign posit_fir_o = fir2_st1;
`endif

  exponent_t ops_te_out;
  logic [FRAC_FULL_SIZE-1:0] ops_frac_full;


  logic [((1 + TE_BITS + FRAC_FULL_SIZE) + 1)-1:0] ops_result;
  fir_ops #(
    .N              (N)
  ) fir_ops_inst (
    .clk_i          (clk_i),
    .rst_i          (rst_i),
    .op_i           (op_i),
    .fir1_i         (fir1),
    .fir2_i         (fir2),
    .fir3_i         (fir3),
    .ops_result_o   (ops_result),
    .fixed_o        (fixed_o)
  );


  normalization #(
    .N              (N),
    .ES             (ES),
    .FIR_TOTAL_SIZE (1 + TE_BITS + FRAC_FULL_SIZE),

    .TE_BITS        (TE_BITS),
    .FRAC_FULL_SIZE (FRAC_FULL_SIZE)
  ) normalization_inst (
    .ops_result_i   (ops_result),
    .p_special_i    (p_special),
    .posit_o        (pout_o)
  );
  


//   logic [((1 + TE_BITS + FRAC_FULL_SIZE) + 1)-1:0] ops_wire_st0;
//   assign ops_wire_st0 =
// `ifdef FLOAT_TO_POSIT
//     (op_st1 === FLOAT_TO_POSIT) ? {float_fir_i, 1'b0} :
// `endif
//     ops_result;

  

endmodule: ppu_core_ops
