/*

iverilog -g2012 -DTEST_BENCH_ROUND_MUL -DN=16 -DES=1  -o round_mul.out \
../src/round_mul.sv \
&& ./round_mul.out


sv2v -DN=16 -DES=1 \
../src/round_mul.sv > round_mul.v

*/
module round_mul #(
        parameter N = `N
    )(
        input  [N-1:0]  posit_in,
        input [(3)-1:0] rounding_signals,
                // input           k_is_oob,
                // input           bit_n_plus_one,
                // input           bits_more,
        output [N-1:0]  posit_rounded_out
    );
    
    function [N-1:0] c2(input [N-1:0] a);
        c2 = ~a + 1'b1;
    endfunction

    wire k_is_oob, bit_n_plus_one, bits_more;
    assign {k_is_oob, bit_n_plus_one, bits_more} = rounding_signals;

    wire sign = posit_in[N-1];

    wire adj;
    assign adj = ((posit_in & 1'b1) | bits_more);

    assign posit_rounded_out = posit_in + (
        ((k_is_oob == 0) && (bit_n_plus_one == 1)) ? 
            sign == 0 ?
                ((posit_in & 1'b1) | bits_more)
                : 
                - ((posit_in & 1'b1) | bits_more)
            : 
        0
    );

endmodule



`ifdef TEST_BENCH_ROUND_MUL
module tb_mul;


endmodule
`endif