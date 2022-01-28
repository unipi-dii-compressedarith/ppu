module compute_rouding #(
        parameter N = 16,
        parameter ES = 1
    )(
        input mant_len,
        input mant_up_shifted,
        input mant_len_diff,
        input k,
        input exp,
        output round_bit,
        output sticky_bit
    );

    assign round_bit = mant_len >= 0 ? 
        mant_up_shifted & (1 << (mant_len_diff - 1)) != 0 : (
            k == N  - 2 - ES  ? 
            exp > 0 && mant_up_shifted > 0 : (
                k == -(N  - 2) ?
                exp > 0 : 0
            )
        );

    assign sticky_bit = mant_len >= 0 ? mant_up_shifted & ((1 << (mant_len_diff - 1)) - 1) != 0 : 0;

endmodule
