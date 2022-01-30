module core_sub #(
        parameter N = 16
    )(
        input mant,
        input te_diff,
        output new_mant,
        output new_te_diff
    );

    wire leading_zeros;

    // cls (

    // ) clz (

    // );

    assign new_te_diff = te_diff - leading_zeros;
    assign new_mant = mant << leading_zeros;

endmodule
