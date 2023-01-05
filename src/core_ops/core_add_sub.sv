module core_add_sub 
    import ppu_pkg::*;
#(
  parameter TE_BITS = -1,
  parameter MANT_SIZE = -1,
  parameter MANT_ADD_RESULT_SIZE = -1
) (
  input                               clk,
  input                               rst,
  input  [               TE_BITS-1:0] te1_in,
  input  [               TE_BITS-1:0] te2_in,
  input  [             MANT_SIZE-1:0] mant1_in,
  input  [             MANT_SIZE-1:0] mant2_in,
  input                               have_opposite_sign,
  output [(MANT_ADD_RESULT_SIZE)-1:0] mant_out,
  output [               TE_BITS-1:0] te_out,
  output                              frac_truncated
);

  function [(MANT_SIZE+MAX_TE_DIFF)-1:0] _c2(input [(MANT_SIZE+MAX_TE_DIFF)-1:0] a);
    _c2 = ~a + 1'b1;
  endfunction


  logic have_opposite_sign_st0, have_opposite_sign_st1;
  assign have_opposite_sign_st0 = have_opposite_sign;

  logic [TE_BITS-1:0] te1, te2_st0, te2_st1;
  wire [MANT_SIZE-1:0] mant1, mant2;
  assign {te1, te2_st0} = {te1_in, te2_in};
  assign {mant1, mant2} = {mant1_in, mant2_in};


  logic [TE_BITS-1:0] te_diff_st0, te_diff_st1;
  assign te_diff_st0 = $signed(te1) - $signed(te2_st0);

  wire [(MANT_SIZE+MAX_TE_DIFF)-1:0] mant1_upshifted, mant2_upshifted;
  assign mant1_upshifted = mant1 << MAX_TE_DIFF;
  assign mant2_upshifted = (mant2 << MAX_TE_DIFF) >> max(0, te_diff_st0);

  logic [(MANT_ADD_RESULT_SIZE)-1:0] mant_sum_st0, mant_sum_st1;
  assign mant_sum_st0 = mant1_upshifted + (have_opposite_sign ? _c2(
      mant2_upshifted
  ) : mant2_upshifted);


  wire [(MANT_ADD_RESULT_SIZE)-1:0] mant_out_core_add;
  wire [TE_BITS-1:0] te_diff_out_core_add;
  core_add #(
    .TE_BITS              (TE_BITS),
    .MANT_ADD_RESULT_SIZE (MANT_ADD_RESULT_SIZE)
  ) core_add_inst (
    .mant                 (mant_sum_st1),
    .te_diff              (te_diff_st1),
    .new_mant             (mant_out_core_add),
    .new_te_diff          (te_diff_out_core_add),
    .frac_truncated       (frac_truncated)
  );


  wire [(MANT_SUB_RESULT_SIZE)-1:0] mant_out_core_sub;
  wire [TE_BITS-1:0] te_diff_out_core_sub;
  core_sub #(
    .TE_BITS              (TE_BITS),
    .MANT_SUB_RESULT_SIZE (MANT_SUB_RESULT_SIZE)
  ) core_sub_inst (
    .mant                 (mant_sum_st1[MANT_SUB_RESULT_SIZE-1:0]),
    .te_diff              (te_diff_st1),
    .new_mant             (mant_out_core_sub),
    .new_te_diff          (te_diff_out_core_sub)
  );

  wire [TE_BITS-1:0] te_diff_updated;
  assign te_diff_updated = have_opposite_sign_st1 ? te_diff_out_core_sub : te_diff_out_core_add;

  assign mant_out = have_opposite_sign_st1 ? {mant_out_core_sub  /*, 1'b0*/} : mant_out_core_add;

  assign te_out = te2_st1 + te_diff_updated;


`ifdef PIPELINE_STAGE
  always_ff @(posedge clk) begin
    if (rst) begin
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
