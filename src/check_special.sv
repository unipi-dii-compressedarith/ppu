module check_special #(
        parameter N = `N    
    )(
        input [N-1:0] bits_in,
        output is_special,
        output is_zero,
        output is_nan
    );

    assign is_zero = bits_in == { N{1'b0} };
    assign is_nan  = bits_in == { {1{1'b1}}, {N-1{1'b0}} };

    assign is_special = is_zero || is_nan;

endmodule
