/*
fast reciprocate.

    *unused*

*/

`define USE_FAST_INVERSE
`ifdef USE_FAST_INVERSE

module fast_recip #(
    parameter N = 3
) (
    input  [N-1:0] p1,
    input  [N-1:0] p2,
    output [N-1:0] p2_fast_recip
);

    /*
def _inv_posit(X: bits, N: usize) -> bits:
    """takes posit bits and returns posit bits"""
    msb = 1 << (N - 1)
    sign_mask = (~((msb | (msb - 1)) >> 1)) & mask(N)
    Y = (X ^ (~sign_mask)) & mask(N)
    Y2 = (X ^ (~msb)) & mask(N)
    return Y, Y2 + 1
*/

    assign p2_fast_recip = (p2 ^ {{1{1'b0}}, {N - 1{1'b1}}}) + 1'b1;

endmodule

`else
