module core_add_sub 
    import ppu_pkg::*;
#(
  parameter TE_BITS = -1,
  parameter MANT_SIZE = -1,
  parameter MANT_ADD_RESULT_SIZE = -1
) (
  input logic                         clk_i,
  input logic                         rst_i,
  input exponent_t                    te1_i,
  input exponent_t                    te2_i,
  input  [             MANT_SIZE-1:0] mant1_i,
  input  [             MANT_SIZE-1:0] mant2_i,
  input                               have_opposite_sign_i,
  output [(MANT_ADD_RESULT_SIZE)-1:0] mant_o,
  output exponent_t                   te_o,
  output                              frac_truncated_o
);

  function [(MANT_SIZE+MAX_TE_DIFF)-1:0] _c2(input [(MANT_SIZE+MAX_TE_DIFF)-1:0] a);
    _c2 = ~a + 1'b1;
  endfunction


  logic have_opposite_sign_st0, have_opposite_sign_st1;
  assign have_opposite_sign_st0 = have_opposite_sign_i;

  exponent_t te1, te2_st0, te2_st1;
  wire [MANT_SIZE-1:0] mant1, mant2;
  assign {te1, te2_st0} = {te1_i, te2_i};
  assign {mant1, mant2} = {mant1_i, mant2_i};


  exponent_t te_diff_st0, te_diff_st1;
  assign te_diff_st0 = $signed(te1) - $signed(te2_st0);

  wire [(MANT_SIZE+MAX_TE_DIFF)-1:0] mant1_upshifted, mant2_upshifted;
  assign mant1_upshifted = mant1 << MAX_TE_DIFF;
  assign mant2_upshifted = (mant2 << MAX_TE_DIFF) >> max(0, te_diff_st0);

  logic [(MANT_ADD_RESULT_SIZE)-1:0] mant_sum_st0, mant_sum_st1;
  assign mant_sum_st0 = mant1_upshifted + (have_opposite_sign_i ? _c2(
      mant2_upshifted
  ) : mant2_upshifted);


  wire [(MANT_ADD_RESULT_SIZE)-1:0] mant_out_core_add;
  exponent_t te_diff_out_core_add;
  core_add #(
    .TE_BITS              (TE_BITS),
    .MANT_ADD_RESULT_SIZE (MANT_ADD_RESULT_SIZE)
  ) core_add_inst (
    .mant_i               (mant_sum_st1),
    .te_diff_i            (te_diff_st1),
    .new_mant_o           (mant_out_core_add),
    .new_te_diff_o        (te_diff_out_core_add),
    .frac_truncated_o     (frac_truncated_o)
  );


  wire [(MANT_SUB_RESULT_SIZE)-1:0] mant_out_core_sub;
  exponent_t te_diff_out_core_sub;
  core_sub #(
    .TE_BITS              (TE_BITS),
    .MANT_SUB_RESULT_SIZE (MANT_SUB_RESULT_SIZE)
  ) core_sub_inst (
    .mant                 (mant_sum_st1[MANT_SUB_RESULT_SIZE-1:0]),
    .te_diff              (te_diff_st1),
    .new_mant             (mant_out_core_sub),
    .new_te_diff          (te_diff_out_core_sub)
  );

  exponent_t te_diff_updated;
  assign te_diff_updated = have_opposite_sign_st1 ? te_diff_out_core_sub : te_diff_out_core_add;

  assign mant_o = have_opposite_sign_st1 ? {mant_out_core_sub  /*, 1'b0*/} : mant_out_core_add;

  assign te_o = te2_st1 + te_diff_updated;


`ifdef PIPELINE_STAGE
  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      te_diff_st1 <= 0;
      mant_sum_st1 <= 0;
      have_opposite_sign_st1 <= 0;
      te2_st1 <= 0;
    end else begin
      te_diff_st1 <= te_diff_st0;
      mant_sum_st1 <= mant_sum_st0;
      have_opposite_sign_st1 <= have_opposite_sign_st0;
      te2_st1 <= te2_st0;
    end
  end
`elsif NO_PIPELINE
  assign te_diff_st1 = te_diff_st0;
  assign mant_sum_st1 = mant_sum_st0;
  assign have_opposite_sign_st1 = have_opposite_sign_st0;
  assign te2_st1 = te2_st0;
`else
  initial $error("Missing define: `core_add_sub`");
`endif

endmodule: core_add_sub
