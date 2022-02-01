module core_add_sub #(
        parameter N = 16
    )(
        input [TE_SIZE-1:0] te1_in,
        input [TE_SIZE-1:0] te2_in,
        input [MANT_SIZE-1:0] mant1_in,
        input [MANT_SIZE-1:0] mant2_in,
        input have_opposite_sign,
        
        output [2*MANT_SIZE-1:0] mant_out,
        output [TE_SIZE-1:0] te_out
    );

    function [N-1:0] max(input [N-1:0] a, b);
        max = a >= b ? a : b;
    endfunction

    function [(2*MANT_SIZE)-1:0] c2(input [(2*MANT_SIZE)-1:0] a);
        c2 = ~a + 1'b1;
    endfunction



    wire [TE_SIZE-1:0] te1, te2;
    wire [MANT_SIZE-1:0] mant1, mant2;
    assign {te1, te2} = {te1_in, te2_in};
    assign {mant1, mant2} = {mant1_in, mant2_in};

    
    wire [TE_SIZE-1:0] te_diff;
    assign te_diff = $signed(te1) - $signed(te2);

    wire [(2*MANT_SIZE)-1:0] mant1_upshifted, mant2_upshifted;
    assign mant1_upshifted = mant1 << N;
    assign mant2_upshifted = (mant2 << N) >> max(0, te_diff);

    wire [(2*MANT_SIZE+1)-1:0] mant_sum;
    assign mant_sum = mant1_upshifted
        + (have_opposite_sign ? 
            c2(mant2_upshifted) : mant2_upshifted
        );
    

    wire [(2*MANT_SIZE)-1:0] mant_out_core_add;
    wire [TE_SIZE-1:0] te_diff_out_core_add;
    core_add #(
        .N(N)
    ) core_add_inst (
        .mant(mant_sum),
        .te_diff(te_diff),
        .new_mant(mant_out_core_add),
        .new_te_diff(te_diff_out_core_add)
    );

    
    wire [(2*MANT_SIZE)-1:0] mant_out_core_sub;
    wire [TE_SIZE-1:0] te_diff_out_core_sub;
    core_sub #(
        .N(N)
    ) core_sub_inst (
        .mant(mant_sum[(2*MANT_SIZE)-1:0]),
        .te_diff(te_diff),
        .new_mant(mant_out_core_sub),
        .new_te_diff(te_diff_out_core_sub)
    );

    wire [TE_SIZE-1:0] te_diff_updated;
    assign te_diff_updated = 
        !have_opposite_sign ? 
        te_diff_out_core_add : te_diff_out_core_sub;

    assign mant_out = 
        !have_opposite_sign ? 
        mant_out_core_add : mant_out_core_sub;
    
    assign te_out = te2 + te_diff_updated;

endmodule
