module ppu_ap_top #(
    parameter WORD = `WORD,
`ifdef FLOAT_TO_POSIT
    parameter FSIZE = `F,
`endif
    parameter N = `N,
    parameter ES = `ES
) (
    input                    ap_clk, ap_rst, ap_ce, ap_start, ap_continue,
    input      [   WORD-1:0] ppu_in1,
    input      [   WORD-1:0] ppu_in2,
    input      [OP_SIZE-1:0] ppu_op,
    output     [   WORD-1:0] ppu_out,
    output                   ap_idle, ap_done, ap_ready,
    output                   ppu_valid_o
);


    ppu_top #(
        .WORD(WORD),
`ifdef FLOAT_TO_POSIT
        .FSIZE(FSIZE),
`endif
        .N(N),
        .ES(ES)
    ) ppu_top_inst (
        .clk_i         (ap_clk),
        .rst_i         (ap_rst),
        .in_valid_i(ap_start | ap_continue),
        .operand1_i     (ppu_in1),
        .operand2_i     (ppu_in2),
        .op_i      (ppu_op),
        .result_o     (ppu_out),
        .out_valid_o (ap_done)
    );

    assign ap_ready = ap_done;
    assign ap_idle = ~ap_start;
    assign ppu_valid_o = ap_done;

endmodule