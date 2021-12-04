/*
iverilog -DTEST_BENCH_DECODE posit_decode.sv clo.sv highest_set.sv && ./a.out
*/
module posit_decode #(
        parameter N = 8,
        parameter S = $clog2(N),
        parameter ES = 0
    )(
        input [N-1:0] bits,
        
        output        is_zero,
        output        is_inf,
        output        sign,
        output        reg_s,
        output [N-1:0] regime_bits,
        output [S-1:0] reg_len,
        output [S-1:0] k,
        output [ES-1:0] exp,
        output [N-1:0] mant
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
    wire [S-1:0]    k;
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
            bits                 = 8'b11101110;
regime_bits_expected = 8'b00000110;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00001110;
#10;

bits                 = 8'b00001000;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000000;
#10;

bits                 = 8'b01101101;
regime_bits_expected = 8'b00000110;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00001101;
#10;

bits                 = 8'b01111011;
regime_bits_expected = 8'b00011110;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000011;
#10;

bits                 = 8'b11101101;
regime_bits_expected = 8'b00000110;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00001101;
#10;

bits                 = 8'b00000011;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000001;
#10;

bits                 = 8'b00110100;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00010100;
#10;

bits                 = 8'b01110110;
regime_bits_expected = 8'b00001110;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000110;
#10;

bits                 = 8'b10110000;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00010000;
#10;

bits                 = 8'b01111101;
regime_bits_expected = 8'b00111110;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000001;
#10;

bits                 = 8'b10101110;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00001110;
#10;

bits                 = 8'b01000111;
regime_bits_expected = 8'b00000010;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000111;
#10;

bits                 = 8'b11011001;
regime_bits_expected = 8'b00000010;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00011001;
#10;

bits                 = 8'b10110001;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00010001;
#10;

bits                 = 8'b00101001;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00001001;
#10;

bits                 = 8'b10000011;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000001;
#10;

bits                 = 8'b11111011;
regime_bits_expected = 8'b00011110;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000011;
#10;

bits                 = 8'b10001011;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000011;
#10;

bits                 = 8'b01010011;
regime_bits_expected = 8'b00000010;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00010011;
#10;

bits                 = 8'b00010011;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000011;
#10;

bits                 = 8'b00111111;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00011111;
#10;

bits                 = 8'b11000010;
regime_bits_expected = 8'b00000010;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000010;
#10;

bits                 = 8'b01011100;
regime_bits_expected = 8'b00000010;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00011100;
#10;

bits                 = 8'b00001011;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000011;
#10;

bits                 = 8'b01101011;
regime_bits_expected = 8'b00000110;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00001011;
#10;

bits                 = 8'b10100100;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000100;
#10;

bits                 = 8'b00100011;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000011;
#10;

bits                 = 8'b11100110;
regime_bits_expected = 8'b00000110;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000110;
#10;

bits                 = 8'b01011010;
regime_bits_expected = 8'b00000010;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00011010;
#10;

bits                 = 8'b01100001;
regime_bits_expected = 8'b00000110;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000001;
#10;

bits                 = 8'b10011010;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00001010;
#10;

bits                 = 8'b01001000;
regime_bits_expected = 8'b00000010;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00001000;
#10;

bits                 = 8'b10101101;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00001101;
#10;

bits                 = 8'b11010100;
regime_bits_expected = 8'b00000010;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00010100;
#10;

bits                 = 8'b01000011;
regime_bits_expected = 8'b00000010;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000011;
#10;

bits                 = 8'b01110100;
regime_bits_expected = 8'b00001110;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000100;
#10;

bits                 = 8'b00101100;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00001100;
#10;

bits                 = 8'b11010001;
regime_bits_expected = 8'b00000010;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00010001;
#10;

bits                 = 8'b01001101;
regime_bits_expected = 8'b00000010;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00001101;
#10;

bits                 = 8'b11010111;
regime_bits_expected = 8'b00000010;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00010111;
#10;

bits                 = 8'b10011000;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00001000;
#10;

bits                 = 8'b00100010;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000010;
#10;

bits                 = 8'b10100101;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000101;
#10;

bits                 = 8'b10111100;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00011100;
#10;

bits                 = 8'b00111101;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00011101;
#10;

bits                 = 8'b01110000;
regime_bits_expected = 8'b00001110;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000000;
#10;

bits                 = 8'b11100011;
regime_bits_expected = 8'b00000110;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000011;
#10;

bits                 = 8'b01100000;
regime_bits_expected = 8'b00000110;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000000;
#10;

bits                 = 8'b10011001;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00001001;
#10;

bits                 = 8'b11101011;
regime_bits_expected = 8'b00000110;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00001011;
#10;

bits                 = 8'b00000001;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000000;
#10;

bits                 = 8'b00111100;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00011100;
#10;

bits                 = 8'b10101011;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00001011;
#10;

bits                 = 8'b00110001;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00010001;
#10;

bits                 = 8'b10101000;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00001000;
#10;

bits                 = 8'b11110111;
regime_bits_expected = 8'b00001110;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000111;
#10;

bits                 = 8'b01011101;
regime_bits_expected = 8'b00000010;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00011101;
#10;

bits                 = 8'b10111011;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00011011;
#10;

bits                 = 8'b10001100;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000100;
#10;

bits                 = 8'b01010000;
regime_bits_expected = 8'b00000010;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00010000;
#10;

bits                 = 8'b11010110;
regime_bits_expected = 8'b00000010;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00010110;
#10;

bits                 = 8'b11110100;
regime_bits_expected = 8'b00001110;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000100;
#10;

bits                 = 8'b01110011;
regime_bits_expected = 8'b00001110;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000011;
#10;

bits                 = 8'b01101111;
regime_bits_expected = 8'b00000110;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00001111;
#10;

bits                 = 8'b01111000;
regime_bits_expected = 8'b00011110;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000000;
#10;

bits                 = 8'b00010000;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000000;
#10;

bits                 = 8'b10001110;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000110;
#10;

bits                 = 8'b10110011;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00010011;
#10;

bits                 = 8'b10010100;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000100;
#10;

bits                 = 8'b00101000;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00001000;
#10;

bits                 = 8'b00111001;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00011001;
#10;

bits                 = 8'b01101001;
regime_bits_expected = 8'b00000110;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00001001;
#10;

bits                 = 8'b10100010;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000010;
#10;

bits                 = 8'b00001001;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000001;
#10;

bits                 = 8'b10010001;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000001;
#10;

bits                 = 8'b01111111;
regime_bits_expected = 8'b01111111;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000000;
#10;

bits                 = 8'b10111000;
regime_bits_expected = 8'b00000001;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00011000;
#10;

bits                 = 8'b11100101;
regime_bits_expected = 8'b00000110;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00000101;
#10;

bits                 = 8'b11011000;
regime_bits_expected = 8'b00000010;
exp_expected         = 8'b00000000;
mant_expected        = 8'b00011000;
#10;

            #10;
		$finish;
    end

endmodule
`endif



