/// Conversion from Fixedpoint to fixed point
/// Fx<FX_M_IN, FX_B_IN> -> Fx<FX_M_OUT, FX_B_OUT>
/// Sign (MSB) is taken into account too.
module fixed_to_fixed 
#(
  /// 
  parameter FX_M_IN  = -1,
  parameter FX_B_IN = -1,
  ///
  parameter FX_M_OUT = -1,
  parameter FX_B_OUT = -1
)(
  input [(1+FX_B_IN)-1:0] fixed_i,
  output [(1+FX_B_OUT)-1:0] fixed_o
);

  generate
    if (FX_M_IN <= FX_M_OUT) begin
      $error("FX_M_IN must be <= than FX_M_OUT");
    end

    if ((FX_B_OUT-FX_M_OUT) >= (FX_B_IN-FX_M_IN)) begin
      $error("FX_B_OUT-FX_M_OUT must be >= than FX_B_IN-FX_M_IN");
    end
  endgenerate

  
  function [N-1:0] mask(unsigned NN);
    mask = (1 << NN) - 1;
  endfunction
  
  
  logic fixed_i_sign;
  logic fixed_o_sign;
  
  logic [FX_M_IN-1:0] fixed_i_int;
  logic [(FX_B_IN-FX_M_IN)-1:0] fixed_i_frac;

  logic [FX_M_OUT-1:0] fixed_o_int;
  logic [(FX_B_OUT-FX_M_OUT)-1:0] fixed_o_frac;


  assign fixed_i_int = fixed_i >> (FX_B_IN - FX_M_IN);
  assign fixed_i_frac = (fixed_i & mask(FX_B_IN - FX_M_IN));


endmodule: fixed_to_fixed

/*
Note: draft. not tested. did not need eventually
*/
