/*
https://www.researchgate.net/publication/284919835_Modular_Design_Of_Fast_Leading_Zeros_Counting_Circuit
*/

module milenkovic #(
        parameter N = 32
    )(
        input [N-1:0] x,
        output [$clog2(N)-1:0] lz,
        output q
    );

    localparam M = N/4;

    wire [M-1:0] a;
    wire [(2*M)-1:0] z_i;

    genvar i;
    generate
        for (i=0; i<M; i=i+1) begin
            nlc #(
            ) nlc_inst (
                .x_k_0(x[N-1 - (M/2 * i) - 0]),
                .x_k_1(x[N-1 - (M/2 * i) - 1]),
                .x_k_2(x[N-1 - (M/2 * i) - 2]),
                .x_k_3(x[N-1 - (M/2 * i) - 3]),
                .a_i(a[i]),
                .z_i(z_i[2*i + 1 : 2*i])
            );
        end
    endgenerate

    wire [1:0] mux_out;
    muxx #(
        .N(M)
    ) muxx_inst (
        .mux_in(z_i),
        .sel({y2, y1, y0}),
        .mux_out(mux_out)
    );

    wire q;
    wire y0, y1, y2;
    bne #(
    ) bne_inst (
        .a0(a[0]),
        .a1(a[1]),
        .a2(a[2]),
        .a3(a[3]),
        .a4(a[4]),
        .a5(a[5]),
        .a6(a[6]),
        .a7(a[7]),
        .q(q),
        .y0(y0),
        .y1(y1),
        .y2(y2)
    );

    assign lz = {y2, y1, y0, mux_out};
endmodule

module nlc #(
        parameter _N = 1
    )(
        input x_k_0,
        input x_k_1,
        input x_k_2,
        input x_k_3,
        output a_i,
        output [(2)-1:0] z_i
    );

    assign a_i = !(x_k_0 | x_k_1 | x_k_2 | x_k_3);
    
    wire z0, z1;
    assign z0 = !(x_k_0 | (x_k_2 & !x_k_1));
    assign z1 = !(x_k_0 | x_k_1);

    assign z_i = {z1, z0};
endmodule

module muxx #(
        parameter N = 8
    )(
        input [(2*N)-1:0] mux_in,
        input [$clog2(N)-1:0] sel,
        output [(2)-1:0] mux_out
    );
    
    assign mux_out = {mux_in[2*sel+1], mux_in[2*sel]};
endmodule


module bne #(
        parameter _N = 1
    )(
        input a0,
        input a1,
        input a2,
        input a3,
        input a4,
        input a5,
        input a6,
        input a7,
        output q,
        output y0,
        output y1,
        output y2
    );

    assign q = a0 & a1 & a2 & a3 & a4 & a5 & a6 & a7;
    assign y2 = a0 & a1 & a2 & a3;
    assign y1 = a0 & a1 & (!a2 | !a3 | (a4 & a5));
    assign y0 = a0 & (!a1 | (a2 & !a3)) | (a0 & a2 & a4 & (!a5 | a6));

endmodule


`ifdef TB_MILANKOVIC
module tb_milenkovic;
    
    parameter N = 32;
    reg [N-1:0] in_i;
    reg val;
    wire [$clog2(N)-1:0] lz;
    wire q;

    reg [$clog2(N)-1:0] lz_expected;
    reg all_zeroes_expected;

    milenkovic #(
        .N(N)
    ) milenkovic_inst (
        .x(in_i),
        .lz(lz),
        .q(q)
    );

    reg diff;
    always_comb begin
        diff = (in_i == 0 && all_zeroes_expected == q) || (in_i != 0 && all_zeroes_expected == q && lz == lz_expected) ? 0 : 'bx;
    end
    
    initial begin
        $dumpfile("tb_milenkovic.vcd");
        $dumpvars(0, tb_milenkovic);

        //         in_i = 32'b0000_0001; val = 1; // expected = 0;
        // #10     in_i = 32'b1000_0011; val = 1; // expected = 0;
        // #10     in_i = 32'b1100_1000; val = 1; // expected = 1;
        // #10     in_i = 32'b0011_0000; val = 1; // expected = 0;
        // #10     in_i = 32'b0101_0101; val = 1; // expected = 1;
        // #10     in_i = 32'b1100_0000; val = 1; // expected = 1;
        // #10     in_i = 32'b1111_1110; val = 1; // expected = 0;
        // #10     in_i = 32'b1000_0001; val = 1; // expected = 0;
        // #10;


        //         in_i = 32'b0000_0001; val = 0; // expected = 0;
        // #10     in_i = 32'b1000_0011; val = 0; // expected = 0;
        // #10     in_i = 32'b1100_1000; val = 0; // expected = 1;
        // #10     in_i = 32'b0011_0000; val = 0; // expected = 0;
        // #10     in_i = 32'b0101_0101; val = 0; // expected = 1;
        // #10     in_i = 32'b1100_0000; val = 0; // expected = 1;
        // #10     in_i = 32'b1111_1110; val = 0; // expected = 0;
        // #10     in_i = 32'b1000_0001; val = 0; // expected = 0;



        `include "tv_lzc.sv"


        #10;
        $finish;
    end




endmodule
`endif
