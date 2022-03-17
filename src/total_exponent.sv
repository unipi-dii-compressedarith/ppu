/*

*/

module total_exponent #(
    parameter N  = 4,
    parameter ES = 1
) (
    input  [ K_SIZE-1:0] k,
`ifndef NO_ES_FIELD
    input  [     ES-1:0] exp,
`endif
    output [TE_SIZE-1:0] total_exp
);


`ifndef NO_ES_FIELD
    assign total_exp = $signed(k) >= 0 ? (k << ES) + exp : (-($signed(-k) << ES) + exp);

    // assign total_exp = (1 << ES) * k + exp;
`else
    assign total_exp = k;
`endif

endmodule
