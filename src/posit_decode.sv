/*
iverilog -DTEST_BENCH_DECODE posit_decode.sv clo.sv highest_set.sv && ./a.out
*/
module posit_decode #(
        parameter N = 8,
        parameter S = $clog2(N),
        parameter ES = 0
    )(
        input [N-1:0]   bits,
        output          is_zero,
        output          is_inf,
        output          sign,
        output          reg_s,
        output [N-1:0]  regime_bits,
        output [S-1:0]  reg_len,
        output [N-1:0]  k,
        output [ES-1:0] exp,
        output [N-1:0]  mant
    );
    function [N-1:0] c2(input [N-1:0] a);
        c2 = ~a + 1'b1;
    endfunction

    function [N-1:0] min(input [N-1:0] a, b);
        min = a < b ? a : b;
    endfunction
          
    wire [N-1:0] mask = {N{1'b1}};
    assign is_zero = bits == {N{1'b0}};
    assign is_inf = bits == {1'b1, {N-1{1'b0}}};
    assign sign = bits[N-1];
    
    wire [N-1:0] u_bits;
    assign u_bits = sign == 0 ? bits : ~bits + 1;

    wire [S-1:0] leading_ones, leading_zeros;

    assign reg_s = u_bits[N-2];

    assign k = reg_s == 1 ? leading_ones - 1 : c2(leading_zeros);
    
    assign reg_len = reg_s == 1 ? min(k + 2, N - 1) : min(c2(k) + 1, N - 1);
    
    assign regime_bits = (u_bits << 1) >> (N - reg_len);

    assign exp = (u_bits << (1 + reg_len)) >> (N - ES);

    assign mant = (u_bits << (1 + reg_len + ES)) >> (1 + reg_len + ES);

    clo #(
        .N(N),
        .S(S)
    ) clo_inst_o (
        .bits               (u_bits << 1),
        .leading_ones       (leading_ones),
        .index_highest_set  ()
    );
    clo #(
        .N(N),
        .S(S)
    ) clo_inst_z (
        .bits               (~u_bits << 1),
        .leading_ones       (leading_zeros),
        .index_highest_set  ()
    );

endmodule



`ifdef TEST_BENCH_DECODE
module tb_posit_decode;
    function [N-1:0] c2(input [N-1:0] a);
        c2 = ~a + 1'b1;
    endfunction
    function [N-1:0] abs(input [N-1:0] in);
        abs = in[N-1] == 0 ? in : c2(in);
    endfunction

    parameter N = 8;
    parameter S = $clog2(N);
    parameter ES = 0;

    reg [N-1:0]     bits;
    wire            is_zero;
    wire            is_inf;
    wire            sign;
    wire            reg_s;
    wire [N-1:0]    regime_bits;
    wire [S-1:0]    reg_len;
    wire [N-1:0]    k;
    wire [ES-1:0]   exp;
    wire [N-1:0]    mant;

    reg [ES-1:0] exp_expected;
    reg [N-1:0] regime_bits_expected, mant_expected;
    reg err;

    reg [N-1:0] diff_exp, diff_regime_bits, diff_mant;
    always @(*) begin
        diff_exp = abs(exp - exp_expected);
        diff_mant = abs(mant - mant_expected);
        diff_regime_bits = abs(regime_bits - regime_bits_expected);
        if (diff_exp == 0 && diff_mant == 0 && diff_regime_bits == 0)err = 0;
        else err = 1'bx;
    end

    posit_decode #(
        .N(N),
        .S(S),
        .ES(ES)
    ) posit_decode_inst (
        .bits           (bits),
        .is_zero        (is_zero),
        .is_inf         (is_inf),
        .sign           (sign),
        .reg_s          (reg_s),
        .regime_bits    (regime_bits),
        .reg_len        (reg_len),
        .k              (k),
        .exp            (exp),
        .mant           (mant)
    );

    initial begin
		$dumpfile("tb_posit_decode.vcd");
	    $dumpvars(0, tb_posit_decode);                        
            
            `include "tb_posit_decode.sv"

            #10;
		$finish;
    end

endmodule
`endif



