module sign_decisor
(
  input                       clk_i,
  input                       rst_i,
  input                       sign1_i,
  input                       sign2_i,
  input                       sign3_i,
  input ppu_pkg::operation_e  op_i,
  output                      sign_o
);

  logic sign1_st1, sign2_st1;

  // delayed by 1 cycle just like the 4 operations underneath.
  assign sign_o = 
    (op_i == ppu_pkg::ADD || op_i == ppu_pkg::SUB) 
    ? sign1_st1 : /* op_i == MUL  || op_i == DIV */
      sign1_st1 ^ sign2_st1;

`ifdef PIPELINE_STAGE
  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      sign1_st1 <= 0;
      sign2_st1 <= 0;
    end else begin
      sign1_st1 <= sign1_i;
      sign2_st1 <= sign2_i;
    end
  end
`else
  assign sign1_st1 = sign1_i;
  assign sign2_st1 = sign2_i;
`endif

endmodule: sign_decisor
