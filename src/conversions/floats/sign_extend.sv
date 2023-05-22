module sign_extend 
#(
  parameter POSIT_TOTAL_EXPONENT_SIZE = 4,
  parameter FLOAT_EXPONENT_SIZE = 18
)(
  input [POSIT_TOTAL_EXPONENT_SIZE-1:0]    posit_total_exponent,
  output [FLOAT_EXPONENT_SIZE-1:0]                float_exponent
  );

  /*
  /// wasteful fancy way
  localparam EXPONENT_SIZE_DIFF = FLOAT_EXPONENT_SIZE - POSIT_TOTAL_EXPONENT_SIZE;

  assign float_exponent = posit_total_exponent >= 0 ? 
    posit_total_exponent : 
    ~( 
      {{EXPONENT_SIZE_DIFF{1'b0}}, (~posit_total_exponent + 1'b1)} 
    ) + 1'b1;
  */

  assign float_exponent = $signed(posit_total_exponent);

endmodule: sign_extend
