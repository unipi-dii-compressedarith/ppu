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

  assign fixed_o = (start_i == 1'b1) ? fixed_i + init_value_i :
                                       fixed_i + fixed_o_st1;

endmodule: accumulator


module tb_accumulator #(
  parameter CLK_FREQ = `CLK_FREQ
);

  parameter FIXED_SIZE = 64;
  
  logic                          clk;
  logic                          rst;
  logic                          start;
  logic signed [FIXED_SIZE-1:0]  init_value = 0;
  logic signed [FIXED_SIZE-1:0]  fixed_in;
  logic signed [FIXED_SIZE-1:0]  fixed_out;

  clk_gen #(
    .CLK_FREQ     (CLK_FREQ)
  ) clk_gen_i (
    .clk_o        (clk)
  );  

  accumulator #(
    .FIXED_SIZE   (FIXED_SIZE)
  ) accumulator_inst (
    .clk_i        (clk),
    .rst_i        (rst),
    .start_i      (start),
    .init_value_i (init_value),
    .fixed_i      (fixed_in),
    .fixed_o      (fixed_out)
  );

  initial begin
    $dumpfile("tb_accumulator.vcd");
    $dumpvars(0, tb_accumulator);
  end

  initial begin
    rst = 1;
    #13;
    fixed_in = 5;
    rst = 0;
    #41;
    @(posedge clk);
    start = 1;
    @(posedge clk);
    start = 0;


    #52;
    
    @(posedge clk);
    fixed_in = -5;

    #100;

    @(posedge clk);
    init_value = -3;
    start = 1;
    @(posedge clk);
    start = 0;

    #100;
    $finish;
  end

endmodule: tb_accumulator
