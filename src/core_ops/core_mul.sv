module core_mul 
  import ppu_pkg::*;
#(
  parameter TE_BITS = -1,
  parameter MANT_SIZE = -1,
  parameter MANT_MUL_RESULT_SIZE = -1
) (
  input                             clk,
  input                             rst,
  input  [             TE_BITS-1:0] te1,
  input  [             TE_BITS-1:0] te2,
  input  [           MANT_SIZE-1:0] mant1,
  input  [           MANT_SIZE-1:0] mant2,
  output [MANT_MUL_RESULT_SIZE-1:0] mant_out,
  output [             TE_BITS-1:0] te_out,
  output                            frac_truncated
);

  logic [TE_BITS-1:0] te_sum_st0, te_sum_st1;
  assign te_sum_st0 = te1 + te2;

  wire [MANT_SUB_RESULT_SIZE-1:0] mant_mul;


  wire mant_carry;
  assign mant_carry = mant_mul[MANT_MUL_RESULT_SIZE-1];

  assign te_out = mant_carry == 1'b1 ? te_sum_st1 + 1'b1 : te_sum_st1;
  assign mant_out = mant_carry == 1'b1 ? mant_mul >> 1 : mant_mul;

  assign frac_truncated = mant_carry && (mant_mul & 1);



`ifdef PIPELINE_STAGE
  always_ff @(posedge clk) begin
    if (rst) begin
      te_sum_st1 <= 0;
    end else begin
      te_sum_st1 <= te_sum_st0;
    end
  end

  // `define PIPELINED_MUL
  `ifdef PIPELINED_MUL
    pp_mul #(
      .M(MANT_SIZE),
      .N(MANT_SIZE)
    ) pp_mul_inst (
      .clk(clk),
      .rst(rst),
      .a(mant1),
      .b(mant2),
      .product(mant_mul)
    );
  `else
    assign mant_mul = mant1 * mant2;
  `endif
`elsif NO_PIPELINE
  assign te_sum_st1 = te_sum_st0;
  assign mant_mul = mant1 * mant2;
`else
  initial $error("Missing define: `core_mul`");
`endif

endmodule: core_mul
