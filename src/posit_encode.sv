/*
iverilog -DTEST_BENCH_ENCODE posit_encode.sv && ./a.out

yosys -p "synth_intel -family max10 -top posit_decode -vqm posit_decode.vqm" posit_decode.sv clo.sv highest_set.sv > yosys_intel.out

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
        output [N-1:0] bits
    );

    function [N-1:0] shl (
            input [N-1:0] bits,
            input [N-1:0] rhs
        );
        shl = rhs > 0 ? bits << rhs : bits;
    endfunction

    assign bits = sign == 0 ? 
        ( 
              shl(bits, N-1) 
            + shl(regime_bits, N-1-reg_len)
            + shl(exp, N-1-reg_len-ES) 
            + mant 
        ) : 
        ( 8'hff ) ;


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
    wire [N-1:0]   bits;

    reg [N-1:0]   bits_expected;
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
        .bits           (bits)
    );

    always @(*) begin
        err = bits == bits_expected ? 0 : 1'bx;
    end

    initial begin
        if (N == 8 && ES == 0) $dumpfile("tb_posit_encode_P8E0.vcd");
        else if (N == 5 && ES == 1) $dumpfile("tb_posit_encode_P5E1.vcd");
        else
        $dumpfile("tb_posit_encode.vcd");

	    $dumpvars(0, tb_posit_encode);                        
            
        

        // bits = 8'b10010010;
        sign = 1;
        reg_s = 1;
        reg_len = 2;
        regime_bits = 8'b00000110;
        exp         = 8'b00000000;
        mant        = 8'b00001110;
        #10;

        bits_expected = 8'b00001000;
        sign = 0;
        reg_s = 0;
        reg_len = 4;
        regime_bits = 8'b00000001;
        exp         = 8'b00000000;
        mant        = 8'b00000000;



        #10;
		$finish;
    end

endmodule
`endif
