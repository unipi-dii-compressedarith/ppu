/// A wrapper around the actual ppu.
module ppu_top 
  import ppu_pkg::*;
#(
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
  input      [OP_BITS-1:0] ppu_op,
  output reg [   WORD-1:0] ppu_out,
  output reg               ppu_valid_o
);


  logic [WORD-1:0] in1_reg, in2_reg, out_reg;
  logic [OP_BITS-1:0] op_reg;
  logic ppu_valid_in_reg;


  ppu #(
    .WORD(WORD),
`ifdef FLOAT_TO_POSIT
    .FSIZE(FSIZE),
`endif
    .N(N),
    .ES(ES)
  ) ppu_inst (
    .clk_i(clk),
    .rst_i(rst),
    .in_valid_i(ppu_valid_in_reg),
    .operand1_i(in1_reg),
    .operand2_i(in2_reg),
    .op_i(operation_e'(op_reg)),
    .result_o(ppu_out),  //.out(out_reg),
    .out_valid_o(ppu_valid_o)
);


always @(posedge clk) begin
  ppu_valid_in_reg <= ppu_valid_in;
  in1_reg <= ppu_in1;
  in2_reg <= ppu_in2;
  op_reg <= ppu_op;
  // ppu_out <= out_reg;
end

endmodule
