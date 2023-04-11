// Flip-Flop with asynchronous active-low reset
// __q: Q output of FF
// __d: D input of FF
// __reset_value: value assigned upon reset
// (__clk: clock input)
// (__arst_n: asynchronous reset, active-low)
`define FF(__q, __d) \
  always_ff @(posedge (clk_i) or posedge (rst_i)) begin \
    if (rst_i) begin                                    \
      __q <= ('b0);                                     \
    end else begin                                      \
      __q <= (__d);                                     \
    end                                                 \
  end
