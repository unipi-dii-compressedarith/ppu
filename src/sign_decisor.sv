module sign_decisor (
    input                sign1,
    input                sign2,
    input  [OP_SIZE-1:0] op,
    output               sign
);

    assign sign = (op == ADD || op == SUB) ? sign1 : sign1 ^ sign2;

endmodule
