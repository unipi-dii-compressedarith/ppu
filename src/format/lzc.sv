module lzc #(
  parameter NUM_BITS = -1
) (
  input  [        NUM_BITS-1:0] bits_i,
  output [$clog2(NUM_BITS)-1:0] lzc_o,
  output                        valid_o
);
  // initial $display("Hello lzc.");
  lzc_internal #(
    .NUM_BITS(NUM_BITS)
  ) l1 (
    .in (bits_i),
    .out(lzc_o),
    .vld(valid_o)
  );
endmodule: lzc

module lzc_internal #(
  parameter NUM_BITS = 8
) (
  input  [        NUM_BITS-1:0] in,
  output [$clog2(NUM_BITS)-1:0] out,
  output                        vld
);
  localparam S = $clog2(NUM_BITS);

  generate
    if (NUM_BITS == 2) begin : gen_blk1
      assign vld = |in;
      assign out = ~in[1] & in[0];
    end else if (NUM_BITS & (NUM_BITS - 1)) begin : gen_blk2
      lzc_internal #(
        .NUM_BITS     (1 << S)
      ) lzc_internal (
        .in           ({in, {((1 << S) - NUM_BITS) {1'b0}}}),
        .out          (out),
        .vld          (vld)
      );
    end else begin : gen_blk3
      wire [S-2:0] out_l, out_h;
      wire out_vl, out_vh;

      lzc_internal #(
        .NUM_BITS     (NUM_BITS >> 1)
      ) lzc_internal_l (
        .in           (in[(NUM_BITS>>1)-1:0]),
        .out          (out_l),
        .vld          (out_vl)
      );

      lzc_internal #(
        .NUM_BITS     (NUM_BITS >> 1)
      ) lzc_internal_h (
        .in           (in[NUM_BITS-1 : NUM_BITS>>1]),
        .out          (out_h),
        .vld          (out_vh)
      );

      assign vld = out_vl | out_vh;
      assign out = out_vh ? {1'b0, out_h} : {out_vl, out_l};
    end
  endgenerate
endmodule: lzc_internal
