module sign_decisor #(
        parameter N = `N   
    )(

        // TODO make sure sign1 and sign2 are the correct ones in case of +/- where posit1 and 2 are swapped if not one larger than the other.
    
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

    assign sign = op[1] == 0 ? sign1 : sign1 ^ sign2;

endmodule
