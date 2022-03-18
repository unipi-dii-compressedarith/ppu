module ppu #(
        parameter WORD = `WORD,
`ifdef FLOAT_TO_POSIT
        parameter FSIZE = `F,
`endif
        parameter N = `N,
        parameter ES = `ES
    )(
        input                       clk,
        input                       rst,
        input [WORD-1:0]            in1,
        input [WORD-1:0]            in2,
        input [OP_SIZE-1:0]         op, /*
                              ADD
                            | SUB
                            | MUL
                            | DIV
                            | F2P
                            | P2F
                            */
        output [WORD-1:0]           out,
        output                      valid_o
    );

    wire [N-1:0] p1, p2, posit;

    assign p1 = in1[N-1:0];
    assign p2 = in2[N-1:0];


    ppu_core_ops #(
        .N(N),
        .ES(ES)
    ) ppu_core_ops_inst (
        .clk(clk),
        .rst(rst),
        .p1(p1),
        .p2(p2),
        .op(op),
`ifdef FLOAT_TO_POSIT
        .float_fir(float_fir_in),
        .posit_fir(posit_fir),
`endif
        .pout(posit)
    );

`ifdef FLOAT_TO_POSIT

    localparam E_I = FLOAT_EXP_SIZE_F`F;
    localparam M_I = FLOAT_MANT_SIZE_F`F;
    localparam E_II = TE_SIZE;
    localparam M_II = FRAC_FULL_SIZE;

    wire [10:0] EI_wire = E_I, MI_wire = M_I, EII_wire = E_II, MII_wire = M_II;

    wire [(1 + FLOAT_EXP_SIZE_F`F + FLOAT_MANT_SIZE_F`F)-1:0] float_fir_out;
    wire [(1 + TE_SIZE + FRAC_FULL_SIZE)-1:0] float_fir_in;

    wire                        __sign = float_fir_out[ (1 + FLOAT_EXP_SIZE_F`F + FLOAT_MANT_SIZE_F`F) - 1 ];
    wire [TE_SIZE-1:0]          __exp  = float_fir_out[ M_I+E_II : M_I ];
    wire [FRAC_FULL_SIZE-1:0]   __frac = float_fir_out[ M_I-1 -: M_II ];

    assign float_fir_in = {__sign, __exp, __frac};
`endif
    wire [FIR_SIZE-1:0] posit_fir;


`ifdef FLOAT_TO_POSIT
    wire [FSIZE-1:0] float_in, float_out;
    assign float_in = in1[FSIZE-1:0];

    float_to_fir #(
        .FSIZE(FSIZE)
    ) float_to_fir_inst (
        .bits(float_in),
        .fir(float_fir_out)
    );


    wire [FSIZE-1:0] float;
    fir_to_float #(
        .N(N),
        .ES(ES),
        .FSIZE(FSIZE)
    ) fir_to_float_inst (
        .fir(posit_fir),
        .float(float_out)
    );
`endif

    assign out =
`ifdef FLOAT_TO_POSIT
        (op == POSIT_TO_FLOAT) ? float_out :
`endif
        posit;


endmodule






`ifdef TEST_BENCH_PPU
`define STRINGIFY(DEFINE) $sformatf("%0s", `"DEFINE`")

module tb_ppu;
    parameter WORD = `WORD;
    parameter N = `N;
    parameter ES = `ES;
    parameter FSIZE = `F;

    parameter ASCII_SIZE = 300;

    reg                       clk;
    reg                       rst;
    reg [WORD-1:0]              in1; 
    reg [WORD-1:0]              in2;
    reg [OP_SIZE-1:0] op;
    reg [ASCII_SIZE:0] op_ascii;
    wire [WORD-1:0] out;

    reg [ASCII_SIZE:0] in1_ascii, in2_ascii, out_ascii, out_gt_ascii;

`ifdef FLOAT_TO_POSIT
    reg [ASCII_SIZE:0] ascii_x, ascii_exp, ascii_frac, out_expected_ascii;

    // reg [FSIZE-1:0] float_bits;
    // reg [N-1:0] posit;
`endif


    reg [WORD-1:0] out_ground_truth;
    reg [N-1:0] pout_hwdiv_expected;
    reg diff_out_ground_truth, diff_pout_hwdiv_exp, pout_off_by_1;
    reg [N:0] test_no;

    reg [100:0] count_errors;

    ppu #(
        .WORD(WORD),
`ifdef FLOAT_TO_POSIT
        .FSIZE(FSIZE),
`endif
        .N(N),
        .ES(ES)
    ) ppu_inst (
        .clk(clk),
        .rst(rst),
        .in1(in1),
        .in2(in2),
        .op(op),
        .out(out)
    );

    initial clk = 0;
    initial rst = 0;
    always begin
        clk = ~clk;
        #5;
    end

    always @(*) begin
        diff_out_ground_truth = out === out_ground_truth ? 0 : 1'bx;
        pout_off_by_1 = abs(out - out_ground_truth) == 0 ? 0 : abs(out - out_ground_truth) == 1 ? 1 : 'bx;
        diff_pout_hwdiv_exp = (op != DIV) ? 'hz : out === pout_hwdiv_expected ? 0 : 1'bx;
    end


    initial begin

        $dumpfile({"tb_ppu_P",`STRINGIFY(`N),"E",`STRINGIFY(`ES),".vcd"});
        $dumpvars(0, tb_ppu);

        if (N == 4 && ES == 0) begin
            `include "../test_vectors/tv_posit_ppu_P4E0.sv"
        end

        if (N == 5 && ES == 1) begin
            `include "../test_vectors/tv_posit_ppu_P5E1.sv"
        end

        if (N == 8 && ES == 0) begin
            `include "../test_vectors/tv_posit_ppu_P8E0.sv"
        end

        if (N == 8 && ES == 1) begin
            `include "../test_vectors/tv_posit_ppu_P8E1.sv"
        end

        if (N == 8 && ES == 4) begin
            `include "../test_vectors/tv_posit_ppu_P8E4.sv"
        end

        if (N == 16 && ES == 0) begin
            `include "../test_vectors/tv_posit_ppu_P16E0.sv"
        end

        if (N == 16 && ES == 1) begin
            `include "../test_vectors/tv_posit_ppu_P16E1.sv"
        end

        if (N == 16 && ES == 2) begin
            `include "../test_vectors/tv_posit_ppu_P16E2.sv"
        end


        if (N == 32 && ES == 2) begin
            `include "../test_vectors/tv_posit_ppu_P32E2.sv"
        end


        #10;
        $finish;
    end

endmodule
`endif
