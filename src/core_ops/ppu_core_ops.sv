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


  localparam STAGES = 4;
  
  ppu_pkg::operation_e                              op[STAGES-1:0];

  ppu_pkg::posit_t                                  p1[STAGES-1:0],
                                                    p2[STAGES-1:0],
                                                    p3[STAGES-1:0];
  
  ppu_pkg::fir_t                                    fir1[STAGES-1:0],
                                                    fir2[STAGES-1:0],
                                                    fir3[STAGES-1:0];

  ppu_pkg::posit_special_t                          p_special[STAGES-1:0];

  logic [`FX_B-1:0]                                 fixed[STAGES-1:0];
  logic [((1 + TE_BITS + FRAC_FULL_SIZE) + 1)-1:0]  ops_result[STAGES-1:0];



  extraction #(
    .N            (N)
  ) extraction_i (
    .p1_i         (p1[0]),
    .p2_i         (p2[0]),
    .p3_i         (p3[0]),
    .op_i         (op[0]),
    .op_o         (op[1]),

    .fir1_o       (fir1[1]),
    .fir2_o       (fir2[1]),
    .fir3_o       (fir3[1]),

    .p_special_o  (p_special[1])
  );

    


  fir_ops #(
    .N              (N)
  ) fir_ops_inst (
    .clk_i          (clk_i),
    .rst_i          (rst_i),
    .op_i           (op[2]),
    .fir1_i         (fir1[2]),
    .fir2_i         (fir2[2]),
    .fir3_i         (fir3[2]),
    .ops_result_o   (ops_result[2]),
    .fixed_o        (fixed[2])
  );


  normalization #(
    .N              (N),
    .ES             (ES),
    .FIR_TOTAL_SIZE (1 + TE_BITS + FRAC_FULL_SIZE),

    .TE_BITS        (TE_BITS),
    .FRAC_FULL_SIZE (FRAC_FULL_SIZE)
  ) normalization_inst (
    .ops_result_i   (ops_result[3]),
    .p_special_i    (p_special[3]),
    .posit_o        (pout_o)
  );




  localparam _PIPE_DEPTH = 0;

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  pipeline #(
    .PIPELINE_DEPTH (_PIPE_DEPTH),
    .DATA_WIDTH     ($bits({{op_i,   p1_i,   p2_i,   p3_i}}))
  ) pipeline_st0 (
    .clk_i          (clk_i),
    .rst_i          (rst_i),
    .data_in        ({op_i,   p1_i,   p2_i,   p3_i}),
    .data_out       ({op[0],  p1[0],  p2[0],  p3[0]})
  );
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  pipeline #(
    .PIPELINE_DEPTH (_PIPE_DEPTH),
    .DATA_WIDTH     ($bits({op[1], fir1[1], fir2[1], fir3[1], p_special[1]}))
  ) pipeline_st1 (
    .clk_i          (clk_i),
    .rst_i          (rst_i),
    .data_in        ({op[1], fir1[1], fir2[1], fir3[1], p_special[1]}),
    .data_out       ({op[2], fir1[2], fir2[2], fir3[2], p_special[2]})
  );
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  pipeline #(
    .PIPELINE_DEPTH (_PIPE_DEPTH),
    .DATA_WIDTH     ($bits({{fixed[2], ops_result[2], p_special[2]}}))
  ) pipeline_st2 (
    .clk_i          (clk_i),
    .rst_i          (rst_i),
    .data_in        ({fixed[2], ops_result[2], p_special[2]}),
    .data_out       ({fixed[3], ops_result[3], p_special[3]})
  );
  assign fixed_o = fixed[3];
  ////////////////////////////////////////////////////////////////////////////////////////////////////


//   logic [((1 + TE_BITS + FRAC_FULL_SIZE) + 1)-1:0] ops_wire_st0;
//   assign ops_wire_st0 =
// `ifdef FLOAT_TO_POSIT
//     (op_st1 === FLOAT_TO_POSIT) ? {float_fir_i, 1'b0} :
// `endif
//     ops_result;

  
  
  
  
  
  
  
  // posit to FIR
  assign posit_fir_o = fir2[2];


endmodule: ppu_core_ops
