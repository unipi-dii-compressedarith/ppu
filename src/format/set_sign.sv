module set_sign 
  import ppu_pkg::c2;
#(
  parameter N = 9
) (
  input  [N-1:0] posit_in,
  input          sign,
  output [N-1:0] posit_out
);

  assign posit_out = sign == 0 ? posit_in : c2(posit_in);

endmodule: set_sign
