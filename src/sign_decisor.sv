module sign_decisor #(
        parameter N = `N   
    )(
        input sign1,
        input sign2,
        input [OP_SIZE-1:0] op,
        output sign
    );

    /*
        00: +
        01: -
        10: *
        11: /
    */

    assign sign = 
        (op == ADD || op == SUB) ? sign1 : sign1 ^ sign2;

endmodule
