/*
a wrapper around the actual ppu.
*/

module ppu_top #(
        parameter WORD = `WORD
`ifdef FLOAT_TO_POSIT
        ,parameter FSIZE = `F
`endif
    )(
        input clk,
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


    ppu #(
        .WORD(WORD),
`ifdef FLOAT_TO_POSIT
        .FSIZE(FSIZE),
`endif
        .N(N),
        .ES(ES),
    ) ppu_inst (
        .in1(in1_reg),
        .in2(in2_reg),
        .op(op_reg),
        .out(out_reg)
    );


    reg [WORD-1:0] in1_reg, in2_reg, out_reg;
    reg [OP_SIZE-1:0] op_reg;

    always @(posedge clk) begin
        in1_reg <= in1;
        in2_reg <= in2;
        op_reg <= op;
        out <= out_reg;
    end

endmodule
