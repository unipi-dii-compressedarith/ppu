module tb_pipelined;
    parameter WORD = `WORD;
    parameter N = `N;
    parameter ES = `ES;
    parameter FSIZE = `F;

    parameter ASCII_SIZE = 300;

    reg                 clk;
    reg                 rst;
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
        .clk        (clk),
        .rst        (rst),
        .ppu_in1    (ppu_in1),
        .ppu_in2    (ppu_in2),
        .ppu_op     (ppu_op),
        .ppu_out    (ppu_out),
        .ppu_valid_o(ppu_valid_o)
    );

    initial clk = 1;
    initial rst = 0;
    always begin
        clk = ~clk;
        #5;
    end

    // always @(*) begin
    //     diff_out_ground_truth = out === out_ground_truth 
    //         ? 0 : 1'bx;
    //     pout_off_by_1 = abs(out - out_ground_truth) == 0 
    //         ? 0 : abs(out - out_ground_truth) == 1 
    //         ? 1 : 'bx;
    //     diff_pout_hwdiv_exp = (op != DIV) ? 'hz : out === pout_hwdiv_expected 
    //         ? 0 : 1'bx;
    // end



    initial begin
        `define STRINGIFY(DEFINE) $sformatf("%0s", `"DEFINE`")

        $dumpfile({"tb_ppu_pipelined_P", `STRINGIFY(`N), "E", `STRINGIFY(`ES), ".vcd"});
        $dumpvars(0, tb_pipelined);

        #5;
        ppu_op  = ADD;
        ppu_in1 = 126;  // 0x73 P<8,0>
        ppu_in2 = 107;  // 0x6b 

        #40;
        $finish;
    end

endmodule
