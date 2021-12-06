/*
iverilog -DTEST_BENCH_ENCODE posit_encode.sv && ./a.out

yosys -p "synth_intel -family max10 -top posit_encode -vqm posit_encode.vqm" posit_encode.sv > yosys_intel.out

*/
module posit_encode #(
        parameter N = 8,
        parameter S = $clog2(N),
        parameter ES = 0
    )(
        input          is_zero,
        input          is_inf,
        input          sign,
        input          reg_s,
        input [N-1:0]  regime_bits,
        input [S-1:0]  reg_len,
        input [N-1:0]  k,
        input [ES-1:0] exp,
        input [N-1:0]  mant,
        output [N-1:0] posit
    );
    
    function [N-1:0] c2(input [N-1:0] a);
        c2 = ~a + 1'b1;
    endfunction
    
    function [N-1:0] shl (
            input [N-1:0] bits,
            input [N-1:0] rhs
        );
        shl = rhs > 0 ? bits << rhs : bits;
    endfunction

    wire [N-1:0] bits, bits_assembled;
    assign bits_assembled = ( 
          shl(sign, N-1)
        + shl(regime_bits, N-1-reg_len)
        + shl(exp, N-1-reg_len-ES)
        + mant
    );

    assign bits = 
        sign == 0 ? bits_assembled : 
                    c2(bits_assembled & ~(1 << (N-1)));

    /*
    ~(1'b1 << (N-1)) === {1'b0, {N-1{1'b1}}}
    */

    assign posit = 
        is_zero === 1 ? 0 : 
        is_inf  === 1 ? (1 << (N-1)) :
                        bits;
            /*  ^^^ 3 equal signs needed to compare against 1'bx, 
                otherwise if `is_zero` or `is_inf` == 1'bx, also 
                `posit` would be 'bX, regardless. */
endmodule


`ifdef TEST_BENCH_ENCODE
module tb_posit_encode;
    function [N-1:0] c2(input [N-1:0] a);
        c2 = ~a + 1'b1;
    endfunction
    function [N-1:0] abs(input [N-1:0] in);
        abs = in[N-1] == 0 ? in : c2(in);
    endfunction

`ifdef N
    parameter N = `N;
`else
    parameter N = 8;
`endif

    parameter S = $clog2(N);

`ifdef ES
    parameter ES = `ES;
`else
    parameter ES = 0;
`endif

    reg            is_zero;
    reg            is_inf;
    reg            sign;
    reg            reg_s;
    reg [N-1:0]    regime_bits;
    reg [S-1:0]    reg_len;
    reg [N-1:0]    k;
    reg [ES-1:0]   exp;
    reg [N-1:0]    mant;
    wire [N-1:0]   posit;

    reg [N-1:0]   posit_expected;
    reg err;

    posit_encode #(
        .N(N),
        .S(S),
        .ES(ES)
    ) posit_encode_inst (
        .is_zero        (is_zero),
        .is_inf         (is_inf),
        .sign           (sign),
        .reg_s          (reg_s),
        .regime_bits    (regime_bits),
        .reg_len        (reg_len),
        .k              (k),
        .exp            (exp),
        .mant           (mant),
        .posit          (posit)
    );

    always @(*) begin
        err = posit == posit_expected ? 0 : 1'bx;
    end

    initial begin
             if (N == 8 && ES == 0) $dumpfile("tb_posit_encode_P8E0.vcd");
        else if (N == 5 && ES == 1) $dumpfile("tb_posit_encode_P5E1.vcd");
        else                        $dumpfile("tb_posit_encode.vcd");

	    $dumpvars(0, tb_posit_encode);                        
            
        if (N == 8 && ES == 0) begin
            posit_expected = 8'b10010010;
            //bits                 = 8'b11101110;
            sign = 1;
            reg_s = 1;
            reg_len = 3;
            regime_bits = 8'b00000110;
            exp         = 8'b00000000;
            mant        = 8'b00001110;
            #10;

            posit_expected = 8'b00001000;
            //bits                 = 8'b00001000;
            sign = 0;
            reg_s = 0;
            reg_len = 4;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00000000;
            #10;

            posit_expected = 8'b01101101;
            //bits                 = 8'b01101101;
            sign = 0;
            reg_s = 1;
            reg_len = 3;
            regime_bits = 8'b00000110;
            exp         = 8'b00000000;
            mant        = 8'b00001101;
            #10;

            posit_expected = 8'b01111011;
            //bits                 = 8'b01111011;
            sign = 0;
            reg_s = 1;
            reg_len = 5;
            regime_bits = 8'b00011110;
            exp         = 8'b00000000;
            mant        = 8'b00000011;
            #10;

            posit_expected = 8'b10010011;
            //bits                 = 8'b11101101;
            sign = 1;
            reg_s = 1;
            reg_len = 3;
            regime_bits = 8'b00000110;
            exp         = 8'b00000000;
            mant        = 8'b00001101;
            #10;

            posit_expected = 8'b00000011;
            //bits                 = 8'b00000011;
            sign = 0;
            reg_s = 0;
            reg_len = 6;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00000001;
            #10;

            posit_expected = 8'b00110100;
            //bits                 = 8'b00110100;
            sign = 0;
            reg_s = 0;
            reg_len = 2;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00010100;
            #10;

            posit_expected = 8'b01110110;
            //bits                 = 8'b01110110;
            sign = 0;
            reg_s = 1;
            reg_len = 4;
            regime_bits = 8'b00001110;
            exp         = 8'b00000000;
            mant        = 8'b00000110;
            #10;

            posit_expected = 8'b11010000;
            //bits                 = 8'b10110000;
            sign = 1;
            reg_s = 0;
            reg_len = 2;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00010000;
            #10;

            posit_expected = 8'b01111101;
            //bits                 = 8'b01111101;
            sign = 0;
            reg_s = 1;
            reg_len = 6;
            regime_bits = 8'b00111110;
            exp         = 8'b00000000;
            mant        = 8'b00000001;
            #10;

            posit_expected = 8'b11010010;
            //bits                 = 8'b10101110;
            sign = 1;
            reg_s = 0;
            reg_len = 2;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00001110;
            #10;

            posit_expected = 8'b01000111;
            //bits                 = 8'b01000111;
            sign = 0;
            reg_s = 1;
            reg_len = 2;
            regime_bits = 8'b00000010;
            exp         = 8'b00000000;
            mant        = 8'b00000111;
            #10;

            posit_expected = 8'b10100111;
            //bits                 = 8'b11011001;
            sign = 1;
            reg_s = 1;
            reg_len = 2;
            regime_bits = 8'b00000010;
            exp         = 8'b00000000;
            mant        = 8'b00011001;
            #10;

            posit_expected = 8'b11001111;
            //bits                 = 8'b10110001;
            sign = 1;
            reg_s = 0;
            reg_len = 2;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00010001;
            #10;

            posit_expected = 8'b00101001;
            //bits                 = 8'b00101001;
            sign = 0;
            reg_s = 0;
            reg_len = 2;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00001001;
            #10;

            posit_expected = 8'b11111101;
            //bits                 = 8'b10000011;
            sign = 1;
            reg_s = 0;
            reg_len = 6;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00000001;
            #10;

            posit_expected = 8'b10000101;
            //bits                 = 8'b11111011;
            sign = 1;
            reg_s = 1;
            reg_len = 5;
            regime_bits = 8'b00011110;
            exp         = 8'b00000000;
            mant        = 8'b00000011;
            #10;

            posit_expected = 8'b11110101;
            //bits                 = 8'b10001011;
            sign = 1;
            reg_s = 0;
            reg_len = 4;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00000011;
            #10;

            posit_expected = 8'b01010011;
            //bits                 = 8'b01010011;
            sign = 0;
            reg_s = 1;
            reg_len = 2;
            regime_bits = 8'b00000010;
            exp         = 8'b00000000;
            mant        = 8'b00010011;
            #10;

            posit_expected = 8'b00010011;
            //bits                 = 8'b00010011;
            sign = 0;
            reg_s = 0;
            reg_len = 3;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00000011;
            #10;

            posit_expected = 8'b00111111;
            //bits                 = 8'b00111111;
            sign = 0;
            reg_s = 0;
            reg_len = 2;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00011111;
            #10;

            posit_expected = 8'b10111110;
            //bits                 = 8'b11000010;
            sign = 1;
            reg_s = 1;
            reg_len = 2;
            regime_bits = 8'b00000010;
            exp         = 8'b00000000;
            mant        = 8'b00000010;
            #10;

            posit_expected = 8'b01011100;
            //bits                 = 8'b01011100;
            sign = 0;
            reg_s = 1;
            reg_len = 2;
            regime_bits = 8'b00000010;
            exp         = 8'b00000000;
            mant        = 8'b00011100;
            #10;

            posit_expected = 8'b00001011;
            //bits                 = 8'b00001011;
            sign = 0;
            reg_s = 0;
            reg_len = 4;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00000011;
            #10;

            posit_expected = 8'b01101011;
            //bits                 = 8'b01101011;
            sign = 0;
            reg_s = 1;
            reg_len = 3;
            regime_bits = 8'b00000110;
            exp         = 8'b00000000;
            mant        = 8'b00001011;
            #10;

            posit_expected = 8'b11011100;
            //bits                 = 8'b10100100;
            sign = 1;
            reg_s = 0;
            reg_len = 2;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00000100;
            #10;

            posit_expected = 8'b00100011;
            //bits                 = 8'b00100011;
            sign = 0;
            reg_s = 0;
            reg_len = 2;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00000011;
            #10;

            posit_expected = 8'b10011010;
            //bits                 = 8'b11100110;
            sign = 1;
            reg_s = 1;
            reg_len = 3;
            regime_bits = 8'b00000110;
            exp         = 8'b00000000;
            mant        = 8'b00000110;
            #10;

            posit_expected = 8'b01011010;
            //bits                 = 8'b01011010;
            sign = 0;
            reg_s = 1;
            reg_len = 2;
            regime_bits = 8'b00000010;
            exp         = 8'b00000000;
            mant        = 8'b00011010;
            #10;

            posit_expected = 8'b01100001;
            //bits                 = 8'b01100001;
            sign = 0;
            reg_s = 1;
            reg_len = 3;
            regime_bits = 8'b00000110;
            exp         = 8'b00000000;
            mant        = 8'b00000001;
            #10;

            posit_expected = 8'b11100110;
            //bits                 = 8'b10011010;
            sign = 1;
            reg_s = 0;
            reg_len = 3;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00001010;
            #10;

            posit_expected = 8'b01001000;
            //bits                 = 8'b01001000;
            sign = 0;
            reg_s = 1;
            reg_len = 2;
            regime_bits = 8'b00000010;
            exp         = 8'b00000000;
            mant        = 8'b00001000;
            #10;

            posit_expected = 8'b11010011;
            //bits                 = 8'b10101101;
            sign = 1;
            reg_s = 0;
            reg_len = 2;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00001101;
            #10;

            posit_expected = 8'b10101100;
            //bits                 = 8'b11010100;
            sign = 1;
            reg_s = 1;
            reg_len = 2;
            regime_bits = 8'b00000010;
            exp         = 8'b00000000;
            mant        = 8'b00010100;
            #10;

            posit_expected = 8'b01000011;
            //bits                 = 8'b01000011;
            sign = 0;
            reg_s = 1;
            reg_len = 2;
            regime_bits = 8'b00000010;
            exp         = 8'b00000000;
            mant        = 8'b00000011;
            #10;

            posit_expected = 8'b01110100;
            //bits                 = 8'b01110100;
            sign = 0;
            reg_s = 1;
            reg_len = 4;
            regime_bits = 8'b00001110;
            exp         = 8'b00000000;
            mant        = 8'b00000100;
            #10;

            posit_expected = 8'b00101100;
            //bits                 = 8'b00101100;
            sign = 0;
            reg_s = 0;
            reg_len = 2;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00001100;
            #10;

            posit_expected = 8'b10101111;
            //bits                 = 8'b11010001;
            sign = 1;
            reg_s = 1;
            reg_len = 2;
            regime_bits = 8'b00000010;
            exp         = 8'b00000000;
            mant        = 8'b00010001;
            #10;

            posit_expected = 8'b01001101;
            //bits                 = 8'b01001101;
            sign = 0;
            reg_s = 1;
            reg_len = 2;
            regime_bits = 8'b00000010;
            exp         = 8'b00000000;
            mant        = 8'b00001101;
            #10;

            posit_expected = 8'b10101001;
            //bits                 = 8'b11010111;
            sign = 1;
            reg_s = 1;
            reg_len = 2;
            regime_bits = 8'b00000010;
            exp         = 8'b00000000;
            mant        = 8'b00010111;
            #10;

            posit_expected = 8'b11101000;
            //bits                 = 8'b10011000;
            sign = 1;
            reg_s = 0;
            reg_len = 3;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00001000;
            #10;

            posit_expected = 8'b00100010;
            //bits                 = 8'b00100010;
            sign = 0;
            reg_s = 0;
            reg_len = 2;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00000010;
            #10;

            posit_expected = 8'b11011011;
            //bits                 = 8'b10100101;
            sign = 1;
            reg_s = 0;
            reg_len = 2;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00000101;
            #10;

            posit_expected = 8'b11000100;
            //bits                 = 8'b10111100;
            sign = 1;
            reg_s = 0;
            reg_len = 2;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00011100;
            #10;

            posit_expected = 8'b00111101;
            //bits                 = 8'b00111101;
            sign = 0;
            reg_s = 0;
            reg_len = 2;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00011101;
            #10;

            posit_expected = 8'b01110000;
            //bits                 = 8'b01110000;
            sign = 0;
            reg_s = 1;
            reg_len = 4;
            regime_bits = 8'b00001110;
            exp         = 8'b00000000;
            mant        = 8'b00000000;
            #10;

            posit_expected = 8'b10011101;
            //bits                 = 8'b11100011;
            sign = 1;
            reg_s = 1;
            reg_len = 3;
            regime_bits = 8'b00000110;
            exp         = 8'b00000000;
            mant        = 8'b00000011;
            #10;

            posit_expected = 8'b01100000;
            //bits                 = 8'b01100000;
            sign = 0;
            reg_s = 1;
            reg_len = 3;
            regime_bits = 8'b00000110;
            exp         = 8'b00000000;
            mant        = 8'b00000000;
            #10;

            posit_expected = 8'b11100111;
            //bits                 = 8'b10011001;
            sign = 1;
            reg_s = 0;
            reg_len = 3;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00001001;
            #10;

            posit_expected = 8'b10010101;
            //bits                 = 8'b11101011;
            sign = 1;
            reg_s = 1;
            reg_len = 3;
            regime_bits = 8'b00000110;
            exp         = 8'b00000000;
            mant        = 8'b00001011;
            #10;

            posit_expected = 8'b00000001;
            //bits                 = 8'b00000001;
            sign = 0;
            reg_s = 0;
            reg_len = 7;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00000000;
            #10;

            posit_expected = 8'b00111100;
            //bits                 = 8'b00111100;
            sign = 0;
            reg_s = 0;
            reg_len = 2;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00011100;
            #10;

            posit_expected = 8'b11010101;
            //bits                 = 8'b10101011;
            sign = 1;
            reg_s = 0;
            reg_len = 2;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00001011;
            #10;

            posit_expected = 8'b00110001;
            //bits                 = 8'b00110001;
            sign = 0;
            reg_s = 0;
            reg_len = 2;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00010001;
            #10;

            posit_expected = 8'b11011000;
            //bits                 = 8'b10101000;
            sign = 1;
            reg_s = 0;
            reg_len = 2;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00001000;
            #10;

            posit_expected = 8'b10001001;
            //bits                 = 8'b11110111;
            sign = 1;
            reg_s = 1;
            reg_len = 4;
            regime_bits = 8'b00001110;
            exp         = 8'b00000000;
            mant        = 8'b00000111;
            #10;

            posit_expected = 8'b01011101;
            //bits                 = 8'b01011101;
            sign = 0;
            reg_s = 1;
            reg_len = 2;
            regime_bits = 8'b00000010;
            exp         = 8'b00000000;
            mant        = 8'b00011101;
            #10;

            posit_expected = 8'b11000101;
            //bits                 = 8'b10111011;
            sign = 1;
            reg_s = 0;
            reg_len = 2;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00011011;
            #10;

            posit_expected = 8'b11110100;
            //bits                 = 8'b10001100;
            sign = 1;
            reg_s = 0;
            reg_len = 4;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00000100;
            #10;

            posit_expected = 8'b01010000;
            //bits                 = 8'b01010000;
            sign = 0;
            reg_s = 1;
            reg_len = 2;
            regime_bits = 8'b00000010;
            exp         = 8'b00000000;
            mant        = 8'b00010000;
            #10;

            posit_expected = 8'b10101010;
            //bits                 = 8'b11010110;
            sign = 1;
            reg_s = 1;
            reg_len = 2;
            regime_bits = 8'b00000010;
            exp         = 8'b00000000;
            mant        = 8'b00010110;
            #10;

            posit_expected = 8'b10001100;
            //bits                 = 8'b11110100;
            sign = 1;
            reg_s = 1;
            reg_len = 4;
            regime_bits = 8'b00001110;
            exp         = 8'b00000000;
            mant        = 8'b00000100;
            #10;

            posit_expected = 8'b01110011;
            //bits                 = 8'b01110011;
            sign = 0;
            reg_s = 1;
            reg_len = 4;
            regime_bits = 8'b00001110;
            exp         = 8'b00000000;
            mant        = 8'b00000011;
            #10;

            posit_expected = 8'b01101111;
            //bits                 = 8'b01101111;
            sign = 0;
            reg_s = 1;
            reg_len = 3;
            regime_bits = 8'b00000110;
            exp         = 8'b00000000;
            mant        = 8'b00001111;
            #10;

            posit_expected = 8'b01111000;
            //bits                 = 8'b01111000;
            sign = 0;
            reg_s = 1;
            reg_len = 5;
            regime_bits = 8'b00011110;
            exp         = 8'b00000000;
            mant        = 8'b00000000;
            #10;

            posit_expected = 8'b00010000;
            //bits                 = 8'b00010000;
            sign = 0;
            reg_s = 0;
            reg_len = 3;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00000000;
            #10;

            posit_expected = 8'b11110010;
            //bits                 = 8'b10001110;
            sign = 1;
            reg_s = 0;
            reg_len = 4;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00000110;
            #10;

            posit_expected = 8'b11001101;
            //bits                 = 8'b10110011;
            sign = 1;
            reg_s = 0;
            reg_len = 2;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00010011;
            #10;

            posit_expected = 8'b11101100;
            //bits                 = 8'b10010100;
            sign = 1;
            reg_s = 0;
            reg_len = 3;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00000100;
            #10;

            posit_expected = 8'b00101000;
            //bits                 = 8'b00101000;
            sign = 0;
            reg_s = 0;
            reg_len = 2;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00001000;
            #10;

            posit_expected = 8'b00111001;
            //bits                 = 8'b00111001;
            sign = 0;
            reg_s = 0;
            reg_len = 2;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00011001;
            #10;

            posit_expected = 8'b01101001;
            //bits                 = 8'b01101001;
            sign = 0;
            reg_s = 1;
            reg_len = 3;
            regime_bits = 8'b00000110;
            exp         = 8'b00000000;
            mant        = 8'b00001001;
            #10;

            posit_expected = 8'b11011110;
            //bits                 = 8'b10100010;
            sign = 1;
            reg_s = 0;
            reg_len = 2;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00000010;
            #10;

            posit_expected = 8'b00001001;
            //bits                 = 8'b00001001;
            sign = 0;
            reg_s = 0;
            reg_len = 4;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00000001;
            #10;

            posit_expected = 8'b11101111;
            //bits                 = 8'b10010001;
            sign = 1;
            reg_s = 0;
            reg_len = 3;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00000001;
            #10;

            posit_expected = 8'b01111111;
            //bits                 = 8'b01111111;
            sign = 0;
            reg_s = 1;
            reg_len = 7;
            regime_bits = 8'b01111111;
            exp         = 8'b00000000;
            mant        = 8'b00000000;
            #10;

            posit_expected = 8'b11001000;
            //bits                 = 8'b10111000;
            sign = 1;
            reg_s = 0;
            reg_len = 2;
            regime_bits = 8'b00000001;
            exp         = 8'b00000000;
            mant        = 8'b00011000;
            #10;

            posit_expected = 8'b10011011;
            //bits                 = 8'b11100101;
            sign = 1;
            reg_s = 1;
            reg_len = 3;
            regime_bits = 8'b00000110;
            exp         = 8'b00000000;
            mant        = 8'b00000101;
            #10;

            posit_expected = 8'b10101000;
            //bits                 = 8'b11011000;
            sign = 1;
            reg_s = 1;
            reg_len = 2;
            regime_bits = 8'b00000010;
            exp         = 8'b00000000;
            mant        = 8'b00011000;
            #10; 
        
        end
       


        #10;
		$finish;
    end

endmodule
`endif
