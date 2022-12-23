/// Posit Processing Unit (PPU)
module ppu
  import ppu_pkg::OP_SIZE;
  import ppu_pkg::FIR_SIZE;
#(
  parameter WORD = `WORD,
  `ifdef FLOAT_TO_POSIT
    parameter FSIZE = `F,
  `endif
  parameter N = `N,
  parameter ES = `ES
) (
  input logic                           clk_i,
  input logic                           rst_i,
  input logic                           in_valid_i,
  input logic                [WORD-1:0] operand1_i,
  input logic                [WORD-1:0] operand2_i,
  input ppu_pkg::operation_e            op_i,
  output                     [WORD-1:0] result_o,
  output                                out_valid_o
);

  wire stall;
  wire [FIR_SIZE-1:0] posit_fir;
  wire [N-1:0] p1, p2, posit;

  assign p1 = operand1_i[N-1:0];
  assign p2 = operand2_i[N-1:0];


  ppu_core_ops #(
    .N            (N),
    .ES           (ES)
  ) ppu_core_ops_inst (
    .clk          (clk_i),
    .rst          (rst_i),
    .p1           (p1),
    .p2           (p2),
    .op           (op_i),
    .op_st2       (),
    .stall        (stall),
    `ifdef FLOAT_TO_POSIT
      .float_fir  (float_fir_in),
      .posit_fir  (posit_fir),
    `endif
    .pout         (posit)
  );

  assign result_o = posit;
  
  // ...
  assign out_valid_o = in_valid_i;

endmodule: ppu
