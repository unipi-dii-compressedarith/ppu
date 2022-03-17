/*

*/

module comparison_against_pacogen #(
    parameter N  = 4,
    parameter ES = 1
) (
    input  [      N-1:0] p1,
    input  [      N-1:0] p2,
    input  [OP_SIZE-1:0] op,
    output [      N-1:0] pout_ppu_core_ops,
    output [      N-1:0] pout_pacogen
);


    ppu_core_ops #(
        .N (N),
        .ES(ES)
    ) ppu_core_ops_inst (
        .p1  (p1),
        .p2  (p2),
        .op  (op),
        .pout(pout_ppu_core_ops)
    );


    posit_div #(
        .N (N),
        .es(ES)
    ) uut (
        .in1  (p1),
        .in2  (p2),
        .start(1'b1),
        .out  (pout_pacogen),  // pout_pacogen
        .inf  (),
        .zero (),
        .done ()
    );

endmodule


`ifdef TEST_BENCH_COMP_PACOGEN
module tb_comparison_against_pacogen;
    parameter ASCII_SIZE = 300;
    parameter N = `N;
    parameter ES = `ES;

    reg [N-1:0] in1, in2;

    reg [N-1:0] p1, p2;
    reg [OP_SIZE-1:0] op;
    reg [(ASCII_SIZE)-1:0] in1_ascii, in2_ascii, out_gt_ascii;
    reg [(ASCII_SIZE)-1:0] op_ascii;
    wire [N-1:0] pout_pacogen, pout_ppu_core_ops;

    reg [N-1:0] out_ground_truth;

    reg [(10)-1:0] diff_pout_ppu_core_ops_analog;

    reg [(ASCII_SIZE)-1:0] p1_ascii, p2_ascii, pout_ascii, pout_gt_ascii;

    reg [N-1:0] pout_ground_truth, pout_hwdiv_expected;
    reg diff_pout_ppu_core_ops, diff_pout_pacogen, ppu_core_ops_off_by_1, pacogen_off_by_1;
    reg [N:0] test_no;

    reg [(ASCII_SIZE)-1:0] count_errors;

    comparison_against_pacogen #(
        .N (N),
        .ES(ES)
    ) comparison_against_pacogen_inst (
        .p1               (in1),
        .p2               (in2),
        .op               (op),
        .pout_ppu_core_ops(pout_ppu_core_ops),
        .pout_pacogen     (pout_pacogen)
    );


    always @(*) begin
        diff_pout_ppu_core_ops = pout_ppu_core_ops === out_ground_truth ? 0 : 1'bx;
        diff_pout_pacogen = pout_pacogen === out_ground_truth ? 0 : 1'bx;
        ppu_core_ops_off_by_1 = abs(pout_ppu_core_ops - out_ground_truth) == 0 ? 0 :
            abs(pout_ppu_core_ops - out_ground_truth) == 1 ? 1 : 'bx;
        pacogen_off_by_1 = abs(pout_pacogen - out_ground_truth) == 0 ? 0 :
            abs(pout_pacogen - out_ground_truth) == 1 ? 1 : 'bx;

        diff_pout_ppu_core_ops_analog = abs(pout_ppu_core_ops - out_ground_truth);
    end

    initial begin

        $dumpfile({"tb_comparison_against_pacogenP", `STRINGIFY(`N), "E", `STRINGIFY(`ES), ".vcd"});

        $dumpvars(0, tb_comparison_against_pacogen);

        if (N == 8 && ES == 0) begin
            `include "../test_vectors/tv_posit_pacogen_P8E0.sv"
        end

        if (N == 16 && ES == 1) begin
            `include "../test_vectors/tv_posit_pacogen_P16E1.sv"
        end

        if (N == 32 && ES == 2) begin
            `include "../test_vectors/tv_posit_pacogen_P32E2.sv"
        end


        #10;
        $finish;
    end

endmodule
`endif
