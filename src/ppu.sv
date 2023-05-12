/// Posit Processing Unit (PPU)
module ppu
  import ppu_pkg::OP_BITS;
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
  input logic                [WORD-1:0] operand3_i,
  input ppu_pkg::operation_e            op_i,
  output logic               [WORD-1:0] result_o,
  output logic                          out_valid_o,
  output logic [`FX_B-1:0]              fixed_o
);

  wire stall;
  ppu_pkg::fir_t posit_fir;
  ppu_pkg::posit_t p1, p2, p3, posit;

  assign p1 = operand1_i[N-1:0];
  assign p2 = operand2_i[N-1:0];
  assign p3 = operand3_i[N-1:0];


  ppu_core_ops #(
    .N            (N),
    .ES           (ES)
  ) ppu_core_ops_inst (
    .clk_i        (clk_i),
    .rst_i        (rst_i),
    .p1_i         (p1),
    .p2_i         (p2),
    .p3_i         (p3),
    .op_i         (op_i),
    .op_o         (),
    .stall_i      (stall),
  `ifdef FLOAT_TO_POSIT
    .float_fir_i  (float_fir_in),
    .posit_fir_o  (posit_fir),
  `endif
    .pout_o       (posit),
    .fixed_o      (fixed_o)
  );

  assign result_o = posit;
  
  // ...
  assign out_valid_o = in_valid_i;

endmodule: ppu
