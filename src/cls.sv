/*

Description:
    cls: count leading ones.
    It wraps the `highest_set` module; returns the number of ones starting from the left:

    e.g:
        bits = 0b11010000 -> 2
        bits = 0b01111000 -> 0
        bits = 0b11100000 -> 3

Usage:
    cd $PROJECT_ROOT/waveforms
    iverilog -g2012 -DN=16 -DTEST_BENCH_CLS -o cls.out ../src/cls.sv ../src/highest_set.sv ../src/utils.sv && ./cls.out

*/


module cls #(
        parameter NUM_BITS = 2
    )(
        input [NUM_BITS-1:0]            bits,
        input                           val,
        output [$clog2(NUM_BITS)-1:0]   leading_set,
        output [$clog2(NUM_BITS)-1:0]   index_highest_set
    );

    highest_set_v1b #(
        .SIZE      (NUM_BITS)
    )
    highest_set_inst_b (
        .bits   (bits),
        .val    (~val),
        .index  (index_highest_set)
    );

    assign leading_set = (NUM_BITS - 1) - index_highest_set;
endmodule




`ifdef TEST_BENCH_CLS
module tb_cls;
    parameter N = `N;

    reg [N-1:0] posit;
    reg         val; // 0 or 1

    wire [S-1:0] leading_ones, leading_zeros, leading_set;
    wire [S-1:0] index_highest_set_1, index_highest_set_2;


    wire [N-1:0] cls_input = posit[N-1] == 0 ? posit : ~posit;


    /* count leading set (ones) */
    cls #(
        .N                  (N)
    ) count_leading_ones (
        .bits               (posit),
        .leading_set        (leading_ones),
        .index_highest_set  (index_highest_set_1)
    );

    /* count leading set (zeros), inputs bits are flipped */
    cls #(
        .N              (N)
    ) count_leading_zeros (
        .bits               (~posit),
        .leading_set        (leading_zeros),
        .index_highest_set  (index_highest_set_2)
    );

    cls #(
        .N              (N)
    ) count_leading_x (
        .bits               (cls_input),
        .val                (val),
        .leading_set        (leading_set),
        .index_highest_set  ()
    );


    initial begin
        $dumpfile("tb_cls.vcd");
        $dumpvars(0, tb_cls);

                posit = 8'b0000_0001; val = 1; // expected = 0;
        #10     posit = 8'b1000_0011; val = 1; // expected = 0;
        #10     posit = 8'b1100_1000; val = 1; // expected = 1;
        #10     posit = 8'b0011_0000; val = 1; // expected = 0;
        #10     posit = 8'b0101_0101; val = 1; // expected = 1;
        #10     posit = 8'b1100_0000; val = 1; // expected = 1;
        #10     posit = 8'b1111_1110; val = 1; // expected = 0;
        #10     posit = 8'b1000_0001; val = 1; // expected = 0;
        #10;


                posit = 8'b0000_0001; val = 0; // expected = 0;
        #10     posit = 8'b1000_0011; val = 0; // expected = 0;
        #10     posit = 8'b1100_1000; val = 0; // expected = 1;
        #10     posit = 8'b0011_0000; val = 0; // expected = 0;
        #10     posit = 8'b0101_0101; val = 0; // expected = 1;
        #10     posit = 8'b1100_0000; val = 0; // expected = 1;
        #10     posit = 8'b1111_1110; val = 0; // expected = 0;
        #10     posit = 8'b1000_0001; val = 0; // expected = 0;


        #10;
        $finish;
    end

endmodule
`endif

