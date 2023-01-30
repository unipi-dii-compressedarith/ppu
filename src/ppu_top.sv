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
  input  logic                    clk_i,
  input  logic                    rst_i,
  input  logic                    in_valid_i,
  input  logic        [WORD-1:0]  operand1_i,
  input  logic        [WORD-1:0]  operand2_i,
  input  logic        [WORD-1:0]  operand3_i,
  input  operation_e              op_i,
  output logic        [WORD-1:0]  result_o,
  output logic                    out_valid_o
);


  logic [WORD-1:0] operand1_reg, operand2_reg, operand3_reg, result_reg;
  logic [OP_BITS-1:0] op_reg;
  logic in_valid_reg, out_valid_reg;

  ppu #(
    .WORD           (WORD),
    `ifdef FLOAT_TO_POSIT
      .FSIZE        (FSIZE),
    `endif
    .N              (N),
    .ES             (ES)
  ) ppu_inst (
    .clk_i          (clk_i),
    .rst_i          (rst_i),
    .in_valid_i     (in_valid_reg),
    .operand1_i     (operand1_reg),
    .operand2_i     (operand2_reg),
    .operand3_i     (operand3_reg),
    .op_i           (operation_e'(op_reg)),
    .result_o       (result_reg),
    .out_valid_o    (out_valid_reg)
);


always_ff @(posedge clk_i) begin
  if (rst_i) begin
    in_valid_reg <= '0;
    operand1_reg <= '0;
    operand2_reg <= '0;
    operand3_reg <= '0;
    op_reg <= '0;

    out_valid_o <= '0;
    result_o <= '0;
  end else begin
    in_valid_reg <= in_valid_i;
    operand1_reg <= operand1_i;
    operand2_reg <= operand2_i;
    operand3_reg <= operand3_i;
    op_reg <= op_i;

    out_valid_o <= out_valid_reg;
    result_o <= result_reg;
  end
end

endmodule: ppu_top
