module input_conditioning 
  import ppu_pkg::*;
#(
  parameter N = -1
) (
  input               [N-1:0] p1_i,
  input               [N-1:0] p2_i,
  input  operation_e          op_i,
  output              [N-1:0] p1_o,
  output              [N-1:0] p2_o,

  output [(
          N               // pout_special_or_trivial
          + 1             // is_special_or_trivial
      )-1:0] special_o
);

  wire [N-1:0] _p1, _p2;
  assign _p1 = p1_i;
  assign _p2 = op_i == SUB ? c2(p2_i) : p2_i;

  wire op_is_add_or_sub;
  assign op_is_add_or_sub = (op_i == ADD || op_i == SUB);

  assign {p1_o, p2_o} = (op_is_add_or_sub && abs(_p2) > abs(_p1)) ? {_p2, _p1} : {_p1, _p2};

  wire is_special_or_trivial;
  wire [N-1:0] pout_special_or_trivial;


  handle_special_or_trivial #(
    .N      (N)
  ) handle_special_or_trivial_inst (
    .op_i   (op_i),
    .p1_i   (p1_i),
    .p2_i   (p2_i),
    .pout_o (pout_special_or_trivial)
  );

  assign is_special_or_trivial =
        op_i === FLOAT_TO_POSIT  /* check required to activate the rightmost mux */
    ? 0 :
        p1_i == ZERO
    || p1_i == NAR
    || p2_i == ZERO
    || p2_i == NAR
    || (op_i == SUB && p1_i == p2_i)
    || (op_i == ADD && p1_i == c2(
        p2_i
    ));


  assign special_o = {pout_special_or_trivial, is_special_or_trivial};

endmodule: input_conditioning
