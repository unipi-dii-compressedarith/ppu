/*
a wrapper around the actual ppu.
*/

module ppu_top #(
    parameter WORD = `WORD,
`ifdef FLOAT_TO_POSIT
    parameter FSIZE = `F,
`endif
    parameter N = `N,
    parameter ES = `ES
) (
    input                    clk,
    input                    rst,
    input                    ppu_valid_in,
    input      [   WORD-1:0] ppu_in1,
    input      [   WORD-1:0] ppu_in2,
    input      [OP_SIZE-1:0] ppu_op,
    output reg [   WORD-1:0] ppu_out,
    output reg               ppu_valid_o
);


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
        .valid_in(ppu_valid_in),
        .in1(in1_reg),
        .in2(in2_reg),
        .op(op_reg),
        .out(ppu_out),  //.out(out_reg),
        .valid_o(ppu_valid_o)
    );


    reg [WORD-1:0] in1_reg, in2_reg, out_reg;
    reg [OP_SIZE-1:0] op_reg;

    always @(posedge clk) begin
        in1_reg <= ppu_in1;
        in2_reg <= ppu_in2;
        op_reg  <= ppu_op;
        // ppu_out <= out_reg;
    end

endmodule
