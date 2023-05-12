module reciprocal_approx 
  import ppu_pkg::*;
  #(
    parameter SIZE = -1
  )(
    input [SIZE-1:0]                   i_data,
    output [(3*SIZE-1-2)-1:0]          o_data
  );

  reg [(SIZE)-1:0] a, b;
  reg [(2*SIZE-1)-1:0] c, d;
  reg [(3*SIZE-1)-1:0] e;
  reg [(3*SIZE-1-2)-1:0] out;

  assign a = i_data;


  /// generated with `scripts/gen_fixed_point_values.py`
  wire [(SIZE)-1:0] fx_1_466  = fx_1_466___N`N;
  wire [(2*SIZE-1)-1:0] fx_1_0012 = fx_1_0012___N`N;


  assign b = fx_1_466 - a;
  assign c = (($signed(a) * $signed(b)) << 1) >> 1;
  assign d = fx_1_0012 - c;
  assign e = $signed(d) * $signed(b);
  assign out = e;

  /// full width output:
  assign o_data = out;

endmodule: reciprocal_approx
