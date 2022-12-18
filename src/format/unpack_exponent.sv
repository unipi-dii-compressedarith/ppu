module unpack_exponent 
  import ppu_pkg::*;
#(
  parameter N  = 4,
  parameter ES = 1
) (
  input  [TE_SIZE-1:0] total_exp,
  output [ K_SIZE-1:0] k
`ifndef NO_ES_FIELD
, output [     ES-1:0] exp
`endif
);

  assign k = total_exp >> ES;

`ifndef NO_ES_FIELD
  assign exp = total_exp - ((1 << ES) * k);
`endif

endmodule: unpack_exponent
