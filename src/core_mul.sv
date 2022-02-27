/*

iverilog -DN=16 -o core_mul.out \
    ../src/core_mul.sv && ./core_mul.out

*/

module core_mul #(
        parameter N = `N
    )(
        input [TE_SIZE-1:0] te1, te2,
        input [MANT_SIZE-1:0] mant1, mant2,
        output [MANT_MUL_RESULT_SIZE-1:0] mant_out,
        output [TE_SIZE-1:0] te_out
    );
    
    wire [TE_SIZE-1:0] te_sum;
    assign te_sum = te1 + te2;

    wire [MANT_SUB_RESULT_SIZE-1:0] mant_mul;
    assign mant_mul = mant1 * mant2;

    wire mant_carry;
    assign mant_carry = mant_mul[MANT_MUL_RESULT_SIZE-1];

    assign te_out = mant_carry == 1'b1 ? te_sum + 1'b1 : te_sum;
    assign mant_out = mant_carry == 1'b1 ? mant_mul >> 1 : mant_mul;

endmodule
