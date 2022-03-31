module core_add_sub #(
    parameter N = 16
) (
    input                               clk,
    input                               rst,
    input  [               TE_SIZE-1:0] te1_in,
    input  [               TE_SIZE-1:0] te2_in,
    input  [             MANT_SIZE-1:0] mant1_in,
    input  [             MANT_SIZE-1:0] mant2_in,
    input                               have_opposite_sign,
    output [(MANT_ADD_RESULT_SIZE)-1:0] mant_out,
    output [               TE_SIZE-1:0] te_out,
    output                              frac_lsb_cut_off
);

    function [(MANT_SIZE+MAX_TE_DIFF)-1:0] _c2(input [(MANT_SIZE+MAX_TE_DIFF)-1:0] a);
        _c2 = ~a + 1'b1;
    endfunction


    logic have_opposite_sign_st0, have_opposite_sign_st1;
    assign have_opposite_sign_st0 = have_opposite_sign;

    logic [TE_SIZE-1:0] te1, te2_st0, te2_st1;
    wire [MANT_SIZE-1:0] mant1, mant2;
    assign {te1, te2_st0} = {te1_in, te2_in};
    assign {mant1, mant2} = {mant1_in, mant2_in};


    logic [TE_SIZE-1:0] te_diff_st0, te_diff_st1;
    assign te_diff_st0 = $signed(te1) - $signed(te2_st0);

    wire [(MANT_SIZE+MAX_TE_DIFF)-1:0] mant1_upshifted, mant2_upshifted;
    assign mant1_upshifted = mant1 << MAX_TE_DIFF;
    assign mant2_upshifted = (mant2 << MAX_TE_DIFF) >> max(0, te_diff_st0);

    logic [(MANT_ADD_RESULT_SIZE)-1:0] mant_sum_st0, mant_sum_st1;
    assign mant_sum_st0 = mant1_upshifted + (have_opposite_sign ? _c2(
        mant2_upshifted
    ) : mant2_upshifted);


    wire [(MANT_ADD_RESULT_SIZE)-1:0] mant_out_core_add;
    wire [TE_SIZE-1:0] te_diff_out_core_add;
    core_add #(
        .N(N)
    ) core_add_inst (
        .mant(mant_sum_st1),
        .te_diff(te_diff_st1),
        .new_mant(mant_out_core_add),
        .new_te_diff(te_diff_out_core_add),
        .frac_lsb_cut_off(frac_lsb_cut_off)
    );


    wire [(MANT_SUB_RESULT_SIZE)-1:0] mant_out_core_sub;
    wire [TE_SIZE-1:0] te_diff_out_core_sub;
    core_sub #(
        .N(N)
    ) core_sub_inst (
        .mant(mant_sum_st1[MANT_SUB_RESULT_SIZE-1:0]),
        .te_diff(te_diff_st1),
        .new_mant(mant_out_core_sub),
        .new_te_diff(te_diff_out_core_sub)
    );

    wire [TE_SIZE-1:0] te_diff_updated;
    assign te_diff_updated = have_opposite_sign_st1 ? te_diff_out_core_sub : te_diff_out_core_add;

    assign mant_out = have_opposite_sign_st1 ? {mant_out_core_sub  /*, 1'b0*/} : mant_out_core_add;

    assign te_out = te2_st1 + te_diff_updated;

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

endmodule
