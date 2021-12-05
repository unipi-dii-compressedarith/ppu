/*

clo: count leading ones.
It wraps the `highest_set` module; returns the number of ones starting from the left:

e.g:
    bits = 0b11010000 -> 2
    bits = 0b01111000 -> 0
    bits = 0b11100000 -> 3


iverilog -DTEST_BENCH clo.sv highest_set.sv && ./a.out
*/


module clo #(
        parameter N = 8,
        parameter S = $clog2(N)
    )(
        input [N-1:0] bits,
        output [S-1:0] leading_ones,
        output [S-1:0] index_highest_set
    );

    highest_set_v1 #(
        .SIZE   (N),
        .VAL    (0)
    )
    highest_set_inst(
        .bits   (bits),
        .index  (index_highest_set)
    );

    assign leading_ones = (N - 1) - index_highest_set;
endmodule




`ifdef TEST_BENCH
module tb_clo;

    parameter N = 8;
    parameter S = $clog2(N);

    reg [N-1:0] bits;
    wire [S-1:0] leading_ones, leading_zeros;
    wire [S-1:0] index_highest_set_1, index_highest_set_2;

    /* count leading ones */
    clo #(
        .N              (N),
        .S              (S)
    ) count_leading_ones (
        .bits           (bits),
        .leading_ones   (leading_ones),
        .index_highest_set(index_highest_set_1)
    );

    /* count leading zeros, inputs bits are flipped */
    clo #(
        .N              (N),
        .S              (S)
    ) count_leading_zeros (
        .bits           (~bits),
        .leading_ones   (leading_zeros),
        .index_highest_set(index_highest_set_2)
    );



    initial begin
        $dumpfile("tb_clo.vcd");
        $dumpvars(0, tb_clo);

                bits = 8'b0000_0001;
        #10     bits = 8'b1000_0011;
        #10     bits = 8'b1100_1000;
        #10     bits = 8'b0011_0000;
        #10     bits = 8'b0101_0101;
        #10     bits = 8'b1100_0000;
        #10     bits = 8'b1111_1110;

        #10;
        $finish;
    end

endmodule
`endif

