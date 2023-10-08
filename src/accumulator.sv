/* 
make -f Makefile_new.mk TOP=tb_accumulator
*/

module accumulator #(
  parameter FIXED_SIZE = -1
)(
  input logic                           clk_i,
  input logic                           rst_i,
  input logic                           start_i,
  input logic signed [FIXED_SIZE-1:0]   init_value_i,
  input logic signed [FIXED_SIZE-1:0]   fixed_i,
  output logic signed [FIXED_SIZE-1:0]  fixed_o
);

  logic signed [FIXED_SIZE-1:0] fixed_o_st1;

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      fixed_o_st1 <= 'b0;
    end else begin
      fixed_o_st1 <= fixed_o;
    end
  end

  assign fixed_o = fixed_i + 
                   ((start_i == 1'b1) ? init_value_i : fixed_o_st1);

endmodule: accumulator
