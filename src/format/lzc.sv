module lzc #(
    parameter NUM_BITS = 16
) (
    input  [        NUM_BITS-1:0] in,
    output [$clog2(NUM_BITS)-1:0] out,
    output                        vld
);
    // initial $display("Hello lzc.");
    lzc_internal #(
        .NUM_BITS(NUM_BITS)
    ) l1 (
        .in (in),
        .out(out),
        .vld(vld)
    );
endmodule

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
                .NUM_BITS(1 << S)
            ) lzc_internal (
                .in ({in, {((1 << S) - NUM_BITS) {1'b0}}}),
                .out(out),
                .vld(vld)
            );
        end else begin : gen_blk3
            wire [S-2:0] out_l, out_h;
            wire out_vl, out_vh;

            lzc_internal #(
                .NUM_BITS(NUM_BITS >> 1)
            ) l (
                .in (in[(NUM_BITS>>1)-1:0]),
                .out(out_l),
                .vld(out_vl)
            );

            lzc_internal #(
                .NUM_BITS(NUM_BITS >> 1)
            ) h (
                .in (in[NUM_BITS-1 : NUM_BITS>>1]),
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

    parameter NUM_BITS = 32;
    reg [NUM_BITS-1:0] in_i;
    reg val;
    wire [$clog2(NUM_BITS)-1:0] lz;
    wire q;

    reg [$clog2(NUM_BITS)-1:0] lz_expected;
    reg all_zeroes_expected;

    lzc_pacogen #(
        .NUM_BITS(NUM_BITS)
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
