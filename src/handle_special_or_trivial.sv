module handle_special_or_trivial 
  import ppu_pkg::*;  
#(
  parameter N = 10
) (
  input  [OP_BITS-1:0] op,
  input  [      N-1:0] p1_in,
  input  [      N-1:0] p2_in,
  output [      N-1:0] pout
);

  wire [N-1:0] p_out_lut_mul, p_out_lut_add, p_out_lut_sub, p_out_lut_div;

  lut_mul #(
    .N(N)
  ) lut_mul_inst (
    .p1(p1_in),
    .p2(p2_in),
    .p_out(p_out_lut_mul)
  );

  lut_add #(
    .N(N)
  ) lut_add_inst (
    .p1(p1_in),
    .p2(p2_in),
    .p_out(p_out_lut_add)
  );

  lut_sub #(
    .N(N)
  ) lut_sub_inst (
    .p1(p1_in),
    .p2(p2_in),
    .p_out(p_out_lut_sub)
  );

  lut_div #(
    .N(N)
  ) lut_div_inst (
    .p1(p1_in),
    .p2(p2_in),
    .p_out(p_out_lut_div)
  );

  assign pout = op == MUL
    ? p_out_lut_mul : op == ADD
    ? p_out_lut_add : op == SUB
    ? p_out_lut_sub : /* op == DIV */
      p_out_lut_div;

endmodule: handle_special_or_trivial


module lut_mul 
  import ppu_pkg::*;
#(
  parameter N = 8
) (
  input      [(N)-1:0] p1,
  input      [(N)-1:0] p2,
  output reg [(N)-1:0] p_out
);

  wire [(2*N)-1:0] addr;
  assign addr = {p1, p2};

  always @(*) begin
    case (p1)
      ZERO:    p_out = p2 == NAR || p2 == ZERO ? p2 : ZERO;
      NAR:     p_out = NAR;
      default: p_out = p2;
    endcase
  end
endmodule: lut_mul

module lut_add 
  import ppu_pkg::*;
#(
  parameter N = 8
) (
  input      [(N)-1:0] p1,
  input      [(N)-1:0] p2,
  output reg [(N)-1:0] p_out
);

  always @(*) begin
    case (p1)
      ZERO:    p_out = p2;
      NAR:     p_out = NAR;
      default: p_out = p2 == c2(p1) ? ZERO : p2 == ZERO ? p1 : NAR;
    endcase
  end
endmodule: lut_add

module lut_sub 
  import ppu_pkg::*;
#(
  parameter N = 8
) (
  input      [(N)-1:0] p1,
  input      [(N)-1:0] p2,
  output reg [(N)-1:0] p_out
);

  always @(*) begin
    case (p1)
      ZERO:    p_out = (p2 == ZERO) || (p2 == NAR) ? p2 : c2(p2);
      NAR:     p_out = NAR;
      default: p_out = p2 == p1 ? ZERO : p2 == ZERO ? p1 : NAR;
    endcase
  end
endmodule: lut_sub

module lut_div 
  import ppu_pkg::*;
#(
  parameter N = 8
) (
  input      [(N)-1:0] p1,
  input      [(N)-1:0] p2,
  output reg [(N)-1:0] p_out
);

  always @(*) begin
    case (p1)
      ZERO:    p_out = (p2 == NAR || p2 == ZERO) ? NAR : ZERO;
      NAR:     p_out = NAR;
      default: p_out = NAR;
    endcase
  end
endmodule: lut_div
