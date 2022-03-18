module lzc_pacogen #(
    parameter N = 32
) (
    input [N-1:0] in,
    output [$clog2(N)-1:0] out,
    output vld
);

    lzc_internal #(
        .N(N)
    ) l1 (
        .in (in),
        .out(out),
        .vld(vld)
    );
endmodule

module lzc_internal #(
    parameter N = 8
) (
    input  [        N-1:0] in,
    output [$clog2(N)-1:0] out,
    output                 vld
);
    localparam S = $clog2(N);

    generate
        if (N == 2) begin
            assign vld = |in;
            assign out = ~in[1] & in[0];
        end else if (N & (N - 1)) begin
            lzc_internal #(
                .N(1 << S)
            ) lzc_internal (
                .in ({in, {((1 << S) - N) {1'b0}}}),
                .out(out),
                .vld(vld)
            );
        end else begin
            wire [S-2:0] out_l, out_h;
            wire out_vl, out_vh;

            lzc_internal #(
                .N(N >> 1)
            ) l (
                .in (in[(N>>1)-1:0]),
                .out(out_l),
                .vld(out_vl)
            );

            lzc_internal #(
                .N(N >> 1)
            ) h (
                .in (in[N-1 : N>>1]),
                .out(out_h),
                .vld(out_vh)
            );

            assign vld = out_vl | out_vh;
            assign out = out_vh ? {1'b0, out_h} : {out_vl, out_l};
        end
    endgenerate
endmodule



`ifdef TB_PACOGEN
module tb_pacogen;

    parameter N = 32;
    reg [N-1:0] in_i;
    reg val;
    wire [$clog2(N)-1:0] lz;
    wire q;

    reg [$clog2(N)-1:0] lz_expected;
    reg all_zeroes_expected;

    lzc_pacogen #(
        .N(N)
    ) lzc_pacogen_inst (
        .in (in_i),
        .out(lz),
        .vld(q)
    );


    reg diff;
    always_comb begin
        diff = (in_i == 0 && all_zeroes_expected == ~q) || (in_i != 0 && all_zeroes_expected == ~q && lz == lz_expected) ? 0 : 'bx;
    end

    initial begin
        $dumpfile("tb_pacogen.vcd");
        $dumpvars(0, tb_pacogen);


        `include "tv_lzc.sv"


        #10;
        $finish;
    end




endmodule
`endif
