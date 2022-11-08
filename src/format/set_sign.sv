module set_sign #(
    parameter N = 9
) (
    input  [N-1:0] posit_in,
    input          sign,
    output [N-1:0] posit_out
);

    assign posit_out = sign == 0 ? posit_in : c2(posit_in);

endmodule
