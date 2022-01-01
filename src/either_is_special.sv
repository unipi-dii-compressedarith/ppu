/*


iverilog -g2012 -DTEST_BENCH_MUL              -DN=16 -DES=1  -o either_is_special.out \
../src/either_is_special.sv && ./either_is_special.out

*/

module either_is_special #(
        parameter N = `N
    )(
        input [1:0] p1_is_special,
        input [1:0] p2_is_special,
        output either_is_special
    );

    assign either_is_special = ((p1_is_special != 0) || (p2_is_special != 0));
endmodule