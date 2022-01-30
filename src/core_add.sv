module core_add #(
        parameter N = 16
    )(
        input [2*MANT_SIZE-1:0] mant,
        input [TE_SIZE-1:0] te_diff,
        output [2*MANT_SIZE-1:0] new_mant,
        output [TE_SIZE-1:0] new_te_diff
    );

    wire mant_carry;
    assign mant_carry = mant[2*MANT_SIZE-1];

    assign new_mant = mant_carry == 1'b1 ? mant >> 1 : mant;
    assign new_te_diff = mant_carry == 1'b1 ? te_diff + 1 : te_diff;

endmodule
