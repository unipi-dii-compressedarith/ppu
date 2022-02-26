module round_posit #(
        parameter N = 10
    )(
        input [N-1:0] posit,
        input round_bit,
        input sticky_bit,
        input k_is_oob,
        input non_zero_frac_field_size,
        output [N-1:0] posit_rounded
);

    wire guard_bit;
    assign guard_bit = posit[0];

    assign posit_rounded = 
        !k_is_oob && round_bit && (!non_zero_frac_field_size || (guard_bit || sticky_bit)) 
        ? posit + 1'b1 : posit;

endmodule
