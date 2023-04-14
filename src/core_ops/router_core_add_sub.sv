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

assign port1_o = port1_i;
assign port2_o = port2_i;

endmodule: router_core_add_sub
