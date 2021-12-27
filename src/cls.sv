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
    
    iverilog -g2012 -DTEST_BENCH_CLS \
    -DN=8 \
    -o cls.out \
    ../src/cls.sv \
    ../src/utils.sv \
    ../src/highest_set.sv && ./cls.out
*/


module cls #(
        parameter N = `N
    )(
        input [N-1:0] posit,
        input          val,
        output [S-1:0] leading_set,
        output [S-1:0] index_highest_set
    );

    highest_set_v1b #(
        .N      (N)
    )
    highest_set_inst_b (
        .bits   (posit << 1),
        .val    (~val),
        .index  (index_highest_set)
    );

    assign leading_set = (N - 1) - index_highest_set;
endmodule




`ifdef TEST_BENCH_CLS
module tb_cls;
`ifdef N
    parameter N = `N;
`else
    $display("missing N");
`endif

    reg [N-1:0] posit;
    reg val; // 0 or 1

    wire [S-1:0] leading_ones, leading_zeros, leading_set;
    wire [S-1:0] index_highest_set_1, index_highest_set_2;


    wire [N-1:0] cls_input = posit[N-1] == 0 ? posit : ~posit;


    /* count leading set (ones) */
    cls #(
        .N              (N)
    ) count_leading_ones (
        .posit          (posit),
        .leading_set    (leading_ones),
        .index_highest_set(index_highest_set_1)
    );

    /* count leading set (zeros), inputs bits are flipped */
    cls #(
        .N              (N)
    ) count_leading_zeros (
        .posit          (~posit),
        .leading_set    (leading_zeros),
        .index_highest_set(index_highest_set_2)
    );

    cls #(
        .N              (N)
    ) count_leading_x (
        .posit          (cls_input),
        .val            (val),
        .leading_set    (leading_set),
        .index_highest_set()
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
        #10;


                posit = 8'b0000_0001; val = 0; // expected = 0;
        #10     posit = 8'b1000_0011; val = 0; // expected = 0;
        #10     posit = 8'b1100_1000; val = 0; // expected = 1;
        #10     posit = 8'b0011_0000; val = 0; // expected = 0;
        #10     posit = 8'b0101_0101; val = 0; // expected = 1;
        #10     posit = 8'b1100_0000; val = 0; // expected = 1;
        #10     posit = 8'b1111_1110; val = 0; // expected = 0;


        #10;
        $finish;
    end

endmodule
`endif

