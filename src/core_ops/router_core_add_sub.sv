/// Router core_add_sub: routes the largest value FIR to port 1 of the adder and the smallest value to port 2
/// 
/// 

module router_core_add_sub
  import ppu_pkg::*;
#(
  parameter SIZE = -1
)(
  input logic [SIZE-1:0]  port1_i,
  input logic [SIZE-1:0]  port2_i,
  
  output logic [SIZE-1:0] port1_o,
  output logic [SIZE-1:0] port2_o
);

  // input unpacking
  logic                 sign1_i, sign2_i;
  exponent_t            te1_i, te2_i;
  logic [MANT_SIZE-1:0] mant1_i, mant2_i;

  
  assign {sign1_i, te1_i, mant1_i} = port1_i;
  assign {sign2_i, te2_i, mant2_i} = port2_i;


  // intermediate values
  logic                 sign1, sign2;
  exponent_t            te1, te2;
  logic [MANT_SIZE-1:0] mant1, mant2;


  
  assign {sign1, te1, mant1, sign2, te2, mant2} =
    ($signed(te1_i) <  $signed(te2_i)) ? {sign2_i, te2_i, mant2_i, sign1_i, te1_i, mant1_i} : // swap
    ($signed(te1_i) == $signed(te2_i)) ? (
                                            (mant1_i < mant2_i) ? {sign2_i, te2_i, mant2_i, sign1_i, te1_i, mant1_i} : 
                                                                  {sign1_i, te1_i, mant1_i, sign2_i, te2_i, mant2_i}
                                          ) : {sign1_i, te1_i, mant1_i, sign2_i, te2_i, mant2_i};
    
  
  assign port1_o = {sign1, te1, mant1};
  assign port2_o = {sign2, te2, mant2};


endmodule: router_core_add_sub
