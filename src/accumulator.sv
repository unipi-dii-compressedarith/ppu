/* 
make -f Makefile_new.mk TOP=tb_accumulator
*/

module accumulator #(
  parameter FIXED_SIZE = -1
)(
  input logic                           clk_i,
  input logic                           rst_i,
  input logic signed [FIXED_SIZE-1:0]   fixed_i,
  output logic signed [FIXED_SIZE-1:0]  fixed_o
);

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      fixed_o <= 'b0;
    end else begin
      fixed_o <= fixed_o + fixed_i;
    end
  end

endmodule: accumulator


module tb_accumulator #(
  parameter CLK_FREQ = `CLK_FREQ
);

  parameter FIXED_SIZE = 64;
  
  logic                          clk_i;
  logic                          rst_i;
  logic signed [FIXED_SIZE-1:0]  fixed_i;
  logic signed [FIXED_SIZE-1:0]  fixed_o;

  clk_gen #(
    .CLK_FREQ     (CLK_FREQ)
  ) clk_gen_i (
    .clk_o        (clk_i)
  );  

  accumulator #(
    .FIXED_SIZE  (FIXED_SIZE)
  ) accumulator_inst (
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .fixed_i    (fixed_i),
    .fixed_o    (fixed_o)
  );

  initial begin
    $dumpfile("tb_accumulator.vcd");
    $dumpvars(0, tb_accumulator);
  end

  initial begin
    rst_i = 1;
    #13;
    rst_i = 0;
    fixed_i = 132;
    #52;
    
    @(posedge clk_i);
    fixed_i = -132;

    #100;
    $finish;
  end

endmodule: tb_accumulator
