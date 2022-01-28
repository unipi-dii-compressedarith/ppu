module core_add #(
        parameter N = 16
    )(
        input mant,
        input te_diff,
        output new_mant,
        output new_te_diff
    );

    
    wire mant_carry;
    assign mant_carry = mant & msb(2 * size + 1) != 0;

    assign new_mant = mant_carry == 1'b1 ? mant >> 1 : mant;
    assign new_te_diff = mant_carry == 1'b1 ? te_diff + 1 : te_diff;

endmodule
