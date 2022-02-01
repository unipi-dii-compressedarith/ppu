module core_sub #(
        parameter N = `N
    )(
        input [(2*MANT_SIZE+1)-1:0] mant,
        input [TE_SIZE-1:0] te_diff,
        output [(2*MANT_SIZE)-1:0] new_mant,
        output [TE_SIZE-1:0] new_te_diff
    );

    wire [TE_SIZE-1:0] leading_zeros;

    // cls (

    // ) clz (

    // );

    assign new_te_diff = te_diff - leading_zeros;
    assign new_mant = mant << leading_zeros;

endmodule
