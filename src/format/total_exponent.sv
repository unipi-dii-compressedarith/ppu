module total_exponent 
  import ppu_pkg::*;
#(
  parameter N  = -1,
  parameter ES = -1
) (
  input  [ K_BITS-1:0] k_i,
`ifndef NO_ES_FIELD
  input  [     ES-1:0] exp_i,
`endif
  output [TE_BITS-1:0] total_exp_o
);


`ifndef NO_ES_FIELD
  assign total_exp_o = $signed(k_i) >= 0 ? (k_i << ES) + exp_i : (-($signed(-k_i) << ES) + exp_i);

  // assign total_exp = (1 << ES) * k_i + exp_i;
`else
  assign total_exp_o = k_i;
`endif

endmodule: total_exponent
