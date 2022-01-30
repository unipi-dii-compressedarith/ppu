module core_add_sub #(
        parameter N = 16
    )(
        input [TE_SIZE-1:0] te1,
        input [TE_SIZE-1:0] te2,
        input [MANT_SIZE-1:0] mant1,
        input [MANT_SIZE-1:0] mant2,
        input have_opposite_sign,
        
        output [2*MANT_SIZE-1:0] mant_out,
        output [TE_SIZE-1:0] te_out
    );

    function [N-1:0] max(
            input [N-1:0] a, b
        );
        max = a >= b ? a : b;
    endfunction

    function [N-1:0] c2(input [N-1:0] a);
        c2 = ~a + 1'b1;
    endfunction

    wire te_diff;
    assign te_diff = te1 - te2;


    wire [2*MANT_SIZE-1:0] mant1_upshifted, mant2_upshifted;
    assign mant1_upshifted = mant1 << N;
    assign mant2_upshifted = (mant2 << N) >> max(0, te_diff);


    assign mant_sum = mant1_upshifted
        + have_opposite_sign ? c2(mant2_upshifted) : mant2_upshifted;


    // assign (mant, te_diff_updated) = match have_opposite_sign {
    //     true => core_sub(size as UInt, mant_sum, te_diff),
    //     false => core_add(size as UInt, mant_sum, te_diff),
    // };

    

    // core_sub (

    // ) core_sub_inst (

    // );

    // core_add (

    // ) core_add_inst (

    // );

    assign te_out = te2 ;//+ te_diff_updated;

endmodule

