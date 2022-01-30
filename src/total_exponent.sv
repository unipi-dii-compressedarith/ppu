/*

*/

module total_exponent #(
        parameter N = `N,
        parameter ES = `ES 
    )(
        input [K_SIZE-1:0] k,
        input [ES-1:0] exp,
        output [TE_SIZE-1:0] total_exp
    );


    // todo: adjust for c2 ans ksign

    assign total_exp = $signed(k) >= 0 ? 
        ( (k << ES) + exp ) : 
        ( -($signed(-k) << ES) + exp );

    // assign total_exp = (1 << ES) * k + exp;

endmodule

