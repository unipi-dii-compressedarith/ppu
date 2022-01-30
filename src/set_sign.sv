module set_sign #(
        parameter N = `N
    )(
        input [N-1:0] posit_in,
        input sign,
        output [N-1:0] posit_out
    );

    function [N-1:0] c2(input [N-1:0] a);
        c2 = ~a + 1'b1;
    endfunction

    assign posit_out = sign == 0 ? posit_in : c2(posit_in);

endmodule