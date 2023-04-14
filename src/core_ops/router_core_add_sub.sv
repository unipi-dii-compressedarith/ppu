/// Router core_add_sub: routes the largest value FIR to port 1 of the adder and the smallest value to port 2
/// 
/// 

module router_core_add_sub
  import ppu_pkg::*;
#(
  parameter TE_BITS = -1,
  parameter MANT_SIZE = -1,
  parameter MANT_ADD_RESULT_SIZE = -1
)(
  input logic                           sign1_i,
  input logic                           sign2_i,
  input exponent_t                      te1_i,
  input exponent_t                      te2_i,
  input  [             MANT_SIZE-1:0]   mant1_i,
  input  [             MANT_SIZE-1:0]   mant2_i,
  
  output logic                          sign1_o,
  output logic                          sign2_o,
  output exponent_t                     te1_o,
  output exponent_t                     te2_o,
  output  [             MANT_SIZE-1:0]  mant1_o,
  output  [             MANT_SIZE-1:0]  mant2_o,

  output logic                          have_opposite_sign_o
);


  assign sign1_o  = sign1_i;
  assign sign2_o  = sign2_i;
  assign te1_o    = te1_i;
  assign te2_o    = te2_i;
  assign mant1_o  = mant1_i;
  assign mant2_o  = mant2_i;



  assign have_opposite_sign_o = sign1_i ^ sign2_i;


endmodule: router_core_add_sub
