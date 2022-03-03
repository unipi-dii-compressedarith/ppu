`define WORD 64
module ppu #(
        parameter WORD = `WORD,
`ifdef FLOAT_TO_POSIT        
        parameter FSIZE = `F,
`endif
        parameter N = `N,
        parameter ES = `ES
    )(
        input [WORD-1:0] in1,
        input [WORD-1:0] in2,
        input [OP_SIZE-1:0] op, /*
                              ADD
                            | SUB
                            | MUL
                            | DIV
                            | F2P
                            | P2F
                            */
        output [WORD-1:0] out
    );

    wire [N-1:0] p1, p2, posit;
    
    assign p1 = in1[N-1:0];
    assign p2 = in2[N-1:0];


    ppu_core_ops #(
        .N(N),
        .ES(ES)
    ) ppu_core_ops_inst (
        .p1(p1),
        .p2(p2),
        .op(op),
`ifdef FLOAT_TO_POSIT
        .float_pif(float_pif),
        .posit_pif(posit_pif),
`endif
        .pout(posit)
    );

`ifdef FLOAT_TO_POSIT
    wire [(1 + FLOAT_EXP_SIZE_F`F + FLOAT_MANT_SIZE_F`F)-1:0] float_pif;
`endif
    wire [PIF_SIZE-1:0] posit_pif;


`ifdef FLOAT_TO_POSIT
    wire [FSIZE-1:0] float_in, float_out;
    assign float_in = in1[FSIZE-1:0];

    float_to_pif #(
        .FSIZE(FSIZE)
    ) float_to_pif_inst (
        .bits(float_in),
        .pif(float_pif)
    );


    wire [FSIZE-1:0] float;
    pif_to_float #(
        .N(N),
        .ES(ES),
        .FSIZE(FSIZE)
    ) pif_to_float_inst (
        .pif(posit_pif),
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
    parameter N = `N;
    parameter ES = `ES;

    reg [N-1:0]  p1, p2;
    reg [OP_SIZE-1:0] op;
    reg [100:0] op_ascii;
    wire [N-1:0] pout;

    reg [300:0] p1_ascii, p2_ascii, pout_ascii, pout_gt_ascii;

    
    reg [N-1:0] pout_ground_truth, pout_hwdiv_expected;
    reg diff_pout_ground_truth, diff_pout_hwdiv_exp, pout_off_by_1;
    reg [N:0] test_no;

    reg [100:0] count_errors;


    ppu_core_ops #(
        .N      (N),
        .ES     (ES)
    ) ppu_core_ops_inst (
        .p1     (p1),
        .p2     (p2),
        .op     (op),
        .pout   (pout)
    );

    
    always @(*) begin
        diff_pout_ground_truth = pout === pout_ground_truth ? 0 : 1'bx;
        pout_off_by_1 = abs(pout - pout_ground_truth) == 0 ? 0 : abs(pout - pout_ground_truth) == 1 ? 1 : 'bx;
        diff_pout_hwdiv_exp = (op != DIV) ? 'hz : pout === pout_hwdiv_expected ? 0 : 1'bx;
    end


    reg [10-1:0] nn, ee;
    initial begin

        $dumpfile({"tb_ppu_P",`STRINGIFY(`N),"E",`STRINGIFY(`ES),".vcd"});
        $dumpvars(0, tb_ppu);                        

        
        if (N == 8 && ES == 0) begin
            `include "../test_vectors/tv_posit_ppu_P8E0.sv"
        end

        if (N == 8 && ES == 4) begin
            `include "../test_vectors/tv_posit_ppu_P8E4.sv"
        end

        if (N == 5 && ES == 1) begin
            `include "../test_vectors/tv_posit_ppu_P5E1.sv"
        end

        if (N == 16 && ES == 1) begin
            `include "../test_vectors/tv_posit_ppu_P16E1.sv"
        end

        if (N == 32 && ES == 2) begin
            `include "../test_vectors/tv_posit_ppu_P32E2.sv"
        end


        #10;
        $finish;
    end

endmodule
`endif
