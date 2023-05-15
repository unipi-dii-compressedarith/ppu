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
  output  ppu_pkg::operation_e                  op_o, // op_st2
  input                                         stall_i,
`ifdef FLOAT_TO_POSIT
  input       [(1+TE_BITS+FRAC_FULL_SIZE)-1:0]  float_fir_i,
  output     ppu_pkg::fir_t                     posit_fir_o,
`endif
  output  ppu_pkg::posit_t                      pout_o,
  ///
  output [`FX_B-1:0]                            fixed_o
);
    
  ppu_pkg::operation_e op_st0, op_st1;
  assign op_st0 = op_i; // alias



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

  
  logic        is_special_or_trivial;
  posit_t      pout_special_or_trivial;
  




  wire [K_BITS-1:0] k1, k2;
`ifndef NO_ES_FIELD
  wire [ES-1:0] exp1, exp2;
`endif

  wire [MANT_SIZE-1:0] mant1, mant2;
  wire [(3*MANT_SIZE)-1:0] mant_out_ops;
  exponent_t te1, te2, te_out_ops;

  logic sign1, sign2;

  
  
  

`ifdef FLOAT_TO_POSIT
  assign posit_fir_o = fir2_st1;
`endif

  exponent_t ops_te_out;
  wire [FRAC_FULL_SIZE-1:0] ops_frac_full;


  wire sign_out_ops;
  wire [((1 + TE_BITS + FRAC_FULL_SIZE) + 1)-1:0] ops_result;
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


  wire frac_truncated;

  


  logic [((1 + TE_BITS + FRAC_FULL_SIZE) + 1)-1:0] ops_wire_st0, ops_wire_st1;

  assign ops_wire_st0 =
`ifdef FLOAT_TO_POSIT
    (op_st1 === FLOAT_TO_POSIT) ? {float_fir_i, 1'b0} :
`endif
    ops_result;

  
  



`ifdef PIPELINE_STAGE
  always @(posedge clk_i) begin
    if (rst == 1'b1) begin
      ops_wire_st1 <= 'b0;
      p_special_st2 <= 'b0;
      p_special_st3 <= 'b0;
      op_o <= 'b0;
    end else begin
      ops_wire_st1 <= ops_wire_st0;
      p_special_st1 <= p_special_st0; // <- new 20221214
      p_special_st2 <= p_special_st1;
      p_special_st3 <= p_special_st2; // p_special_st3 <= (op_st1 === DIV) ? p_special_st2 : p_special_st1;
      op_o <= op_st1;
    end
  end
`else
  
  
  // assign ops_wire_st1 = ops_wire_st0;
  // assign p_special_st1 = p_special_st0; // <- new 20221214
  // assign p_special_st2 = p_special_st1;
  // assign p_special_st3 = p_special_st2; // p_special_st3 <= (op_st1 === DIV) ? p_special_st2 : p_special_st1;
  // assign op_o = op_st1;
`endif
endmodule: ppu_core_ops
