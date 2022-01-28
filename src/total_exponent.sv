/*

*/

module total_exponent #(
        parameter N = 16,
        parameter ES = 1 
    )(
        input [($clog2(N)+1) - 1:0] k,
        input [ES-1:0] exp,
        output [TE_SIZE-1:0] total_exp
    );

    assign total_exp = (1 << ES) * k + exp;

endmodule

