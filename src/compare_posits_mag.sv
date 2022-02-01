module compare_posits_mag #(
        parameter N = `N
    )(
        input [N-1:0] p1,
        input sign1,
        input [N-1:0] p2,
        input sign2,
        output swap_posits
    );

    function [N-1:0] c2(input [N-1:0] a);
        c2 = ~a + 1'b1;
    endfunction

    wire [N-1:0] abs_p1, abs_p2;
    assign abs_p1 = sign1 ? c2(p1) : p1;
    assign abs_p2 = sign2 ? c2(p2) : p2;

    assign swap_posits = abs_p2 > abs_p1;

endmodule