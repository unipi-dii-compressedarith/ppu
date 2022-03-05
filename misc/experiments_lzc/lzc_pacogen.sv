// module LOD_N #(
module lzc_pacogen #(

        parameter N = 32,
        parameter S = $clog2(N)
    )(
        input   [N-1:0] in,
        output  [S-1:0] out
    );
    wire vld;
    LOD #(.N(N)) l1 (in, out, vld);
endmodule

module LOD #(
        parameter N = 8,
        parameter S = $clog2(N)
    )(
        input   [N-1:0] in,
        output  [S-1:0] out,
        output          vld
    );

    generate
        if (N == 2) begin
            assign vld = |in;
            assign out = ~in[1] & in[0];
        end else if (N & (N-1)) begin
            //LOD #(1<<S) LOD ({1<<S {1'b0}} | in,out,vld);
            LOD #(
                .N      (1<<S)
            ) LOD (
                .in({in, {((1<<S) - N) {1'b0}}}),
                .out(out),
                .vld(vld));
        end else begin
            wire [S-2:0] out_l, out_h;
            wire out_vl, out_vh;
            
            LOD #(
                .N      (N >> 1)
            ) l (
                .in     (in[(N>>1)-1:0]), 
                .out    (out_l),
                .vld    (out_vl));
            
            LOD #(
                .N      (N >> 1)
            ) h (
                .in     (in[N-1 : N>>1]),
                .out    (out_h),
                .vld    (out_vh));

            assign vld = out_vl | out_vh;
            assign out = out_vh ? {1'b0, out_h} : {out_vl, out_l};
        end
    endgenerate
endmodule
