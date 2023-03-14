//`define A // remove this
`ifdef A
module input_conditioning 
  import ppu_pkg::*;
#(
  parameter N = -1
) (
  input  posit_t            p1_i,
  input  posit_t            p2_i,
  input  posit_t            p3_i,
  input  operation_e        op_i,
  output posit_t            p1_o,
  output posit_t            p2_o,
  output posit_t            p3_o,
  output posit_special_t    p_special_o // `pout_special_or_trivial` + `is_special_or_trivial` tag
);

  posit_t _p1, _p2;
  assign _p1 = p1_i;
  assign _p2 = (op_i == SUB) ? c2(p2_i) : p2_i;

  logic op_is_add_or_sub;
  assign op_is_add_or_sub = (op_i == ADD || op_i == SUB);

  assign {p1_o, p2_o} = (op_is_add_or_sub && abs(_p2) > abs(_p1)) ? {_p2, _p1} : {_p1, _p2};

  logic is_special_or_trivial;
  posit_t pout_special_or_trivial;


  handle_special_or_trivial #(
    .N      (N)
  ) handle_special_or_trivial_inst (
    .op_i   (op_i),
    .p1_i   (p1_i),
    .p2_i   (p2_i),
    .p3_i   (p3_i),
    .pout_o (pout_special_or_trivial)
  );

  assign is_special_or_trivial =
        op_i === F2P  /* check required to activate the rightmost mux */
    ? 0 :
        p1_i == ZERO
    || p1_i == NAR
    || p2_i == ZERO
    || p2_i == NAR
    || (op_i == SUB && p1_i == p2_i)
    || (op_i == ADD && p1_i == c2(
        p2_i
    ));


  assign p_special_o.posit.bits = pout_special_or_trivial;
  assign p_special_o.special_tag = is_special_or_trivial;

endmodule: input_conditioning
`else

module input_conditioning 
  import ppu_pkg::*;
#(
  parameter N = -1
) (
  input  posit_t            p1_i,
  input  posit_t            p2_i,
  input  posit_t            p3_i,
  input  operation_e        op_i,
  output posit_t            p1_o,
  output posit_t            p2_o,
  output posit_t            p3_o,
  output posit_special_t    p_special_o // `pout_special_or_trivial` + `is_special_or_trivial` tag
);


  assign p1_o = p1_i;
  assign p2_o = p2_i;
  assign p3_o = p3_i;

  assign p_special_o.special_tag = 1'b0;

endmodule: input_conditioning

`endif


/*
 
p1  p2  p3         (p1 * p2) + p3 
0    0     0              0      
0    0     NaN            NaN
0    0     p3             p3

0    NaN    0             NaN
0    NaN    NaN           NaN
0    NaN    p3            NaN

0    p2     0             0
0    p2     NaN           NaN
0    p2     p3            p3


*/

