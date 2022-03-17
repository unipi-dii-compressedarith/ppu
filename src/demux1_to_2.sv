/*
iverilog -DTEST_DEMUX demux1_to_2.sv && ./a.out
*/
module demux1_to_2 #(
    parameter N = 10
) (
    input  [(N)-1:0] demux_in,
    input            sel,
    output [(N)-1:0] demux_out_0,
    output [(N)-1:0] demux_out_1
);

    wire [(2*N)-1:0] demux_out;
    assign demux_out = sel == 0 ? demux_in : (demux_in << N);

    assign {demux_out_1, demux_out_0} = demux_out;
endmodule


`ifdef TEST_DEMUX
module tb_demux1_to_2;

    parameter N = 22;
    reg  [(N)-1:0] demux_in;
    reg            sel;
    wire [(N)-1:0] demux_out_0;
    wire [(N)-1:0] demux_out_1;

    demux1_to_2 #(
        .N(N)
    ) demux1_to_2_inst (
        .demux_in(demux_in),
        .sel(sel),
        .demux_out_0(demux_out_0),
        .demux_out_1(demux_out_1)
    );

    initial begin
        $dumpfile("tb_demux1_to_2.vcd");
        $dumpvars(0, tb_demux1_to_2);

        demux_in = 123;
        sel = 0;
        #10;
        sel = 1;
        #10;
        sel = 2;
        #10;
        sel = 3;

        #10;
        $finish;
    end

endmodule
`endif
