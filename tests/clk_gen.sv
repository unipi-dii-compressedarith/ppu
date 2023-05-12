module clk_gen #(
  parameter CLK_FREQ = 1 // MHz
)(
  output logic clk_o
);

  initial begin 
    #1.23;
    clk_o = 0;
    forever #((1000.0/CLK_FREQ) / 2.0)  clk_o = !clk_o;
  end

endmodule: clk_gen
