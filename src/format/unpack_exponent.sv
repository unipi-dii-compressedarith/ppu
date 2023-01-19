module unpack_exponent 
  import ppu_pkg::*;
#(
  parameter N  = -1,
  parameter ES = -1
) (
  input  exponent_t     total_exp_i,
  output [ K_BITS-1:0]  k_o
`ifndef NO_ES_FIELD
, output [     ES-1:0]  exp_o
`endif
);

  assign k_o = total_exp_i >> ES;

`ifndef NO_ES_FIELD
  assign exp_o = total_exp_i - ((1 << ES) * k_o);
`endif

endmodule: unpack_exponent
