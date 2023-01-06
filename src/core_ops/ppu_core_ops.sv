module ppu_core_ops 
  import ppu_pkg::*;
#(
  parameter N = -1,
  parameter ES = -1
`ifdef FLOAT_TO_POSIT
  ,parameter FSIZE = -1
`endif
)(
  input                                           clk_i,
  input                                           rst_i,
  input           [N-1:0]                         p1_i,
  input           [N-1:0]                         p2_i,
  input ppu_pkg::operation_e                      op_i,
  output ppu_pkg::operation_e                     op_o, // op_st2
  input                                           stall_i,
`ifdef FLOAT_TO_POSIT
  input       [(1+TE_BITS+FRAC_FULL_SIZE)-1:0]    float_fir_i,
  output      [(FIR_SIZE)-1:0]                    posit_fir_o,
`endif
  output      [N-1:0]                             pout_o
);
    
  ppu_pkg::operation_e op_st0, op_st1;
  assign op_st0 = op_i; // alias


  wire [K_BITS-1:0] k1, k2;
`ifndef NO_ES_FIELD
  wire [ES-1:0] exp1, exp2;
`endif

  wire [MANT_SIZE-1:0] mant1, mant2;
  wire [(3*MANT_SIZE)-1:0] mant_out_ops;
  wire [TE_BITS-1:0] te1, te2, te_out_ops;

  wire sign1, sign2;

  wire [N-1:0]      p1_cond, p2_cond;
  wire              is_special_or_trivial;
  wire [N-1:0]      pout_special_or_trivial;
  
  logic [(N+1)-1:0] special_st0, special_st1, special_st2, special_st3;
  input_conditioning #(
    .N          (N)
  ) input_conditioning (
    .p1_i       (p1_i),
    .p2_i       (p2_i),
    .op_i       (op_st0),
    .p1_o       (p1_cond),
    .p2_o       (p2_cond),
    .special_o  (special_st0)
  );

  assign is_special_or_trivial = special_st3[0];
  assign pout_special_or_trivial = special_st3 >> 1;

  logic [FIR_SIZE-1:0] fir1_st0, fir1_st1;
  logic [FIR_SIZE-1:0] fir2_st0, fir2_st1;

  assign fir1_st1 = fir1_st0;
  assign fir2_st1 = fir2_st0;
  assign op_st1 = op_st0;

  posit_to_fir #(
    .N(N),
    .ES(ES)
  ) posit_to_fir1 (
    .p_cond(p1_cond),
    .fir(fir1_st0)
  );

  wire [N-1:0] posit_in_posit_to_fir2;
  assign posit_in_posit_to_fir2 =
`ifdef FLOAT_TO_POSIT
    (op_st0 == POSIT_TO_FLOAT) ? p2_i :
`endif
    p2_cond;

  posit_to_fir #(
    .N(N),
    .ES(ES)
  ) posit_to_fir2 (
    .p_cond(posit_in_posit_to_fir2),
    .fir(fir2_st0)
  );

`ifdef FLOAT_TO_POSIT
  assign posit_fir_o = fir2_st1;
`endif

  wire [TE_BITS-1:0] ops_te_out;
  wire [FRAC_FULL_SIZE-1:0] ops_frac_full;


  wire sign_out_ops;
  wire [((1 + TE_BITS + FRAC_FULL_SIZE) + 1)-1:0] ops_result;
  ops #(
    .N              (N)
  ) ops_inst (
    .clk_i          (clk_i),
    .rst_i          (rst_i),
    .op_i           (op_st1),
    .fir1_i         (fir1_st1),
    .fir2_i         (fir2_st1),
    .ops_result_o   (ops_result)
  );


  wire frac_truncated;

  wire [N-1:0] pout_non_special;


  reg [((1 + TE_BITS + FRAC_FULL_SIZE) + 1)-1:0] ops_wire_st0, ops_wire_st1;

  assign ops_wire_st0 =
`ifdef FLOAT_TO_POSIT
    (op_st1 === FLOAT_TO_POSIT) ? {float_fir_i, 1'b0} :
`endif
    ops_result;

  
  fir_to_posit #(
    .N(N),
    .ES(ES),
    .FIR_TOTAL_SIZE(1 + TE_BITS + FRAC_FULL_SIZE)
  ) fir_to_posit_inst (
    .ops_in(ops_wire_st1),
    .posit(pout_non_special)
  );

  assign pout_o = is_special_or_trivial ? pout_special_or_trivial : pout_non_special;

`ifdef PIPELINE_STAGE
  always @(posedge clk_i) begin
    if (rst == 1'b1) begin_i
      ops_wire_st1 <= 'b0;
      special_st2 <= 'b0;
      special_st3 <= 'b0;
      op_o <= 'b0;
    end else begin
      ops_wire_st1 <= ops_wire_st0;
      special_st1 <= special_st0; // <- new 20221214
      special_st2 <= special_st1;
      special_st3 <= special_st2; // special_st3 <= (op_st1 === DIV) ? special_st2 : special_st1;
      op_o <= op_st1;
    end
  end
`else
  assign ops_wire_st1 = ops_wire_st0;
  assign special_st1 = special_st0; // <- new 20221214
  assign special_st2 = special_st1;
  assign special_st3 = special_st2; // special_st3 <= (op_st1 === DIV) ? special_st2 : special_st1;
  assign op_o = op_st1;
`endif
endmodule: ppu_core_ops
