module sign_decisor 
  import ppu_pkg::*;
(
  input                clk,
  input                rst,
  input                sign1,
  input                sign2,
  input  [OP_SIZE-1:0] op,
  output               sign
);

  logic sign1_st1, sign2_st1;

  // delayed by 1 cycle just like the 4 operations underneath.
  assign sign = 
    (op == ADD || op == SUB) 
    ? sign1_st1 : /* op == MUL  || op == DIV */
      sign1_st1 ^ sign2_st1;

`ifdef PIPELINE_STAGE
  always_ff @(posedge clk) begin
    if (rst) begin
      sign1_st1 <= 0;
      sign2_st1 <= 0;
    end else begin
      sign1_st1 <= sign1;
      sign2_st1 <= sign2;
    end
  end
`else
  assign sign1_st1 = sign1;
  assign sign2_st1 = sign2;
`endif

endmodule: sign_decisor
