module round #(
        parameter N = `N

    )(
        input [N-1:0] posit,
        input round_bit,
        input sticky_bit,
        input k_is_oob,
        input mant_field_size_not_null,
        output [N-1:0] posit_rounded
);

    wire guard_bit;
    assign guard_bit = posit[0];

    assign posit_rounded = !k_is_oob && round_bit && (!mant_field_size_not_null || (guard_bit || sticky_bit)) ?
        posit + 1 : posit;

endmodule
