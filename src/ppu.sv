/// Posit Processing Unit (PPU)
module ppu
  import ppu_pkg::*;
#(
  parameter WORD = `WORD,
`ifdef FLOAT_TO_POSIT
  parameter FSIZE = `F,
`endif
  parameter N = `N,
  parameter ES = `ES
) (
  input                clk,
  input                rst,
  input                valid_in,
  input  [   WORD-1:0] in1,
  input  [   WORD-1:0] in2,
  input  [OP_SIZE-1:0] op,
                      /*ADD
                      | SUB
                      | MUL
                      | DIV
                      | F2P
                      | P2F
                      */
  output [   WORD-1:0] out,
  output               valid_o
);

  wire stall;
  wire [OP_SIZE-1:0] op_st2;
  wire [FIR_SIZE-1:0] posit_fir;
  wire [N-1:0] p1, p2, posit;

  assign p1 = in1[N-1:0];
  assign p2 = in2[N-1:0];


  ppu_core_ops #(
    .N (N),
    .ES(ES)
  ) ppu_core_ops_inst (
    .clk(clk),
    .rst(rst),
    .p1(p1),
    .p2(p2),
    .op(op),
    .op_st2(op_st2),
    .stall(stall),
`ifdef FLOAT_TO_POSIT
    .float_fir(float_fir_in),
    .posit_fir(posit_fir),
`endif
    .pout(posit)
  );

  assign out = posit;
  assign valid_o = 1'b1;

endmodule: ppu
