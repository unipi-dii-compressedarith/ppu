
module unpack_exponent #(
        parameter N = `N,
        parameter ES = `ES
    )(  
        input [TE_SIZE-1 :0] total_exp
        
        output [($clog2(N)+1)-1:0] k,
        output [ES-1:0] exp
    );

    assign k = total_exp >> ES;
    assign exp = total_exp - ((1 << ES) * k);

endmodule
