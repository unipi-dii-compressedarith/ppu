`ifdef TB_PIPELINED
`timescale 1ns / 1ps
module tb_pipelined;
    parameter WORD = `WORD;
    parameter N = `N;
    parameter ES = `ES;
    parameter FSIZE = `F;

    parameter ASCII_SIZE = 300;

    reg                 clk;
    reg                 rst;
    reg                 ppu_valid_in;
    reg  [    WORD-1:0] ppu_in1;
    reg  [    WORD-1:0] ppu_in2;
    reg  [ OP_SIZE-1:0] ppu_op;
    reg  [ASCII_SIZE:0] op_ascii;
    wire [    WORD-1:0] ppu_out;
    wire                ppu_valid_o;

    reg [ASCII_SIZE:0] in1_ascii, in2_ascii, out_ascii, out_gt_ascii;

`ifdef FLOAT_TO_POSIT
    reg [ASCII_SIZE:0] ascii_x, ascii_exp, ascii_frac, out_expected_ascii;

    // reg [FSIZE-1:0] float_bits;
    // reg [N-1:0] posit;
`endif


    reg [WORD-1:0] out_ground_truth;
    reg [   N-1:0] pout_hwdiv_expected;
    reg diff_out_ground_truth, diff_pout_hwdiv_exp, pout_off_by_1;
    reg [  N:0] test_no;

    reg [100:0] count_errors;


    ppu_top #(
        .WORD(WORD),
`ifdef FLOAT_TO_POSIT,
        .FSIZE(FSIZE),
`endif
        .N(N),
        .ES(ES)
    ) ppu_top_inst (
        .clk         (clk),
        .rst         (rst),
        .ppu_valid_in(ppu_valid_in),
        .ppu_in1     (ppu_in1),
        .ppu_in2     (ppu_in2),
        .ppu_op      (ppu_op),
        .ppu_out     (ppu_out),
        .ppu_valid_o (ppu_valid_o)
    );

    initial clk = 1;
    initial rst = 0;
    always begin
        clk = ~clk;
        #5;
    end

    always @(*) begin
        op_ascii = rst == 1 
            ? 'bz : ppu_op === ADD 
            ? "ADD" : ppu_op === MUL
            ? "MUL" : ppu_op === SUB
            ? "SUB" : ppu_op === DIV
            ? "DIV" : 'bz;
    end

    //////////////////////////////////////////////////////////////////
    ////// log to file //////
    integer f;
    initial f = $fopen("output.log", "w");

    always @(posedge clk) begin
        if (ppu_valid_in) $fwrite(f, "i %h %h %h\n", ppu_in1, ppu_op, ppu_in2);
    end

    always @(negedge clk) begin
        if (ppu_valid_o) $fwrite(f, "o %h\n", ppu_out);
    end
    //////////////////////////////////////////////////////////////////


    initial begin
        `define STRINGIFY(DEFINE) $sformatf("%0s", `"DEFINE`")

        $dumpfile({"tb_ppu_pipelined_P", `STRINGIFY(`N), "E", `STRINGIFY(`ES), ".vcd"});
        $dumpvars(0, tb_pipelined);
    end

    initial begin
        rst = 1;
        ppu_valid_in = 0;
        #9;
        rst = 0;
        #20;



        ppu_valid_in = 1;
        ppu_op = MUL;
        ppu_in1 = 'h7e;
        ppu_in2 = 'he4;
        #10;


        ppu_valid_in = 1;
        ppu_op = SUB;
        ppu_in1 = 250;
        ppu_in2 = 34;
        #10;

        ppu_valid_in = 1;
        ppu_op = ADD;
        ppu_in1 = 12;
        ppu_in2 = 13;
        #10;

        ppu_valid_in = 1;
        ppu_op = ADD;
        ppu_in1 = 12;
        ppu_in2 = 0;
        #10;


        ppu_valid_in = 0;
        ppu_op = ADD;
        ppu_in1 = 'h71a0;
        ppu_in2 = 'h2c66;
        #10;


        ppu_valid_in = 1;
        ppu_op = DIV;
        ppu_in1 = 120;
        ppu_in2 = 0;
        #10;

        ppu_valid_in = 1;
        ppu_op = MUL;
        ppu_in1 = 4522;
        ppu_in2 = 12417;
        #9;

        ppu_valid_in = 1;
        ppu_op = MUL;
        ppu_in1 = 4522;
        ppu_in2 = 0;
        #9;

        ppu_valid_in = 1;
        ppu_op = DIV;
        ppu_in1 = 15;
        ppu_in2 = 15;
        #10;


        ppu_valid_in = 1;
        ppu_op = MUL;
        ppu_in1 = 6;
        ppu_in2 = (1 << (N - 1));
        #10;


        ppu_valid_in = 1;
        ppu_op = SUB;
        ppu_in1 = 4;
        ppu_in2 = 0;
        #10;


        ppu_valid_in = 1;
        ppu_op = DIV;
        ppu_in1 = 41;
        ppu_in2 = 1;
        #10;


        ppu_valid_in = 1;
        ppu_op = DIV;
        ppu_in1 = 42;
        ppu_in2 = 16;
        #10;

        ppu_valid_in = 1;
        ppu_op = ADD;
        ppu_in1 = 422;
        ppu_in2 = 0;
        #10;



        //////////////////////////////////////////////



        ppu_valid_in = 1;
        ppu_op = SUB;
        ppu_in1 = 334;
        ppu_in2 = 28;
        #10;

        `include "../test_vectors/tv_pipelined.sv"


        ppu_valid_in = 0;
        ppu_op = 'bz;
        ppu_in1 = 'bz;
        ppu_in2 = 'bz;
        #10;

        #50;
        $finish;
        $fclose(f);
    end

endmodule
`endif
