module core_sub #(
        parameter N = 4
    )(
        input [MANT_SUB_RESULT_SIZE-1:0] mant,
        input [TE_SIZE-1:0] te_diff,
        output [MANT_SUB_RESULT_SIZE-1:0] new_mant,
        output [TE_SIZE-1:0] new_te_diff
    );

    wire [($clog2(MANT_SUB_RESULT_SIZE))-1:0] leading_zeros;

    cls #(
        .NUM_BITS(MANT_SUB_RESULT_SIZE)
    ) clz (
        .bits               (mant[MANT_SUB_RESULT_SIZE-1:0]),
        .val                (1'b0),
        .leading_set        (leading_zeros),
        .index_highest_set  ()
    );

    assign new_te_diff = te_diff - leading_zeros;
    assign new_mant = mant << leading_zeros;

endmodule
