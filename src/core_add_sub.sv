module core_add_sub #(
        parameter N = 16
    )(
        input [TE_SIZE-1:0] te1_in,
        input [TE_SIZE-1:0] te2_in,
        input [MANT_SIZE-1:0] mant1_in,
        input [MANT_SIZE-1:0] mant2_in,
        input have_opposite_sign,
        
        output [(MANT_ADD_RESULT_SIZE)-1:0] mant_out,
        output [TE_SIZE-1:0] te_out
    );

    function [(MANT_SIZE+MAX_TE_DIFF)-1:0] _c2(input [(MANT_SIZE+MAX_TE_DIFF)-1:0] a);
        _c2 = ~a + 1'b1;
    endfunction

    wire [TE_SIZE-1:0] te1, te2;
    wire [MANT_SIZE-1:0] mant1, mant2;
    assign {te1, te2} = {te1_in, te2_in};
    assign {mant1, mant2} = {mant1_in, mant2_in};

    
    wire [TE_SIZE-1:0] te_diff;
    assign te_diff = $signed(te1) - $signed(te2);

    wire [(MANT_SIZE+MAX_TE_DIFF)-1:0] mant1_upshifted, mant2_upshifted;
    assign mant1_upshifted = mant1 << MAX_TE_DIFF;
    assign mant2_upshifted = (mant2 << MAX_TE_DIFF) >> max(0, te_diff);

    wire [(MANT_ADD_RESULT_SIZE)-1:0] mant_sum;
    assign mant_sum = 
        mant1_upshifted + (have_opposite_sign 
            ? _c2(mant2_upshifted) : mant2_upshifted
        );
    

    wire [(MANT_ADD_RESULT_SIZE)-1:0] mant_out_core_add;
    wire [TE_SIZE-1:0] te_diff_out_core_add;
    core_add #(
        .N(N)
    ) core_add_inst (
        .mant(mant_sum),
        .te_diff(te_diff),
        .new_mant(mant_out_core_add),
        .new_te_diff(te_diff_out_core_add)
    );

    
    wire [(MANT_ADD_RESULT_SIZE)-1:0] mant_out_core_sub;
    wire [TE_SIZE-1:0] te_diff_out_core_sub;
    core_sub #(
        .N(N)
    ) core_sub_inst (
        .mant(mant_sum[MANT_ADD_RESULT_SIZE-2:0]),
        .te_diff(te_diff),
        .new_mant(mant_out_core_sub),
        .new_te_diff(te_diff_out_core_sub)
    );

    wire [TE_SIZE-1:0] te_diff_updated;
    assign te_diff_updated = 
        have_opposite_sign 
        ? te_diff_out_core_sub : te_diff_out_core_add;

    assign mant_out = 
        have_opposite_sign 
        ? {mant_out_core_sub/*, 1'b0*/} : mant_out_core_add;
    
    assign te_out = te2 + te_diff_updated;

endmodule
