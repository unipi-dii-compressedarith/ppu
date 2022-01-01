/*


iverilog -g2012 -DTEST_BENCH_MUL              -DN=16 -DES=1  -o mul_special.out \
../src/mul_special.sv && ./mul_special.out

*/
module mul_special #(
        parameter N = `N
    )(
        input [1:0] p1_is_special,
        input [1:0] p2_is_special,
        output [N-1:0] pout_special
    );

    wire p1_is_zero, p1_is_nan;
    wire p2_is_zero, p2_is_nan;

    assign {p1_is_zero, p1_is_nan} = p1_is_special;
    assign {p2_is_zero, p2_is_nan} = p2_is_special;

    wire zero_times_anything, nan_times_anything, zero_times_nan;

    /// 0 * anything = 0
    assign zero_times_anything = ((p1_is_zero == 1) && (p2_is_special == 0)) || ((p2_is_zero == 1) && (p1_is_special == 0));
    /// nan * anything = nan
    assign nan_times_anything = ((p1_is_nan == 1) && (p2_is_special == 0)) || ((p2_is_nan == 1) && (p1_is_special == 0));
    /// 0 * nan = nan
    assign zero_times_nan = ((p1_is_zero == 1) && (p2_is_nan == 1)) || ((p2_is_zero == 1) && (p1_is_nan == 1));

    assign pout_special = ((nan_times_anything == 1) || (zero_times_nan == 1)) ? { {1'b1}, {N-1{1'b0}} } : {N{1'b0}} ;
endmodule