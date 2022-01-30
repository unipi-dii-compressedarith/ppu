/*

Description:
    Posit encoder.

Usage:
    cd $PROJECT_ROOT/waveforms
    
    iverilog -g2012 -DTEST_BENCH_ENCODE -DNO_ES_FIELD -DN=8 -DES=0 -o posit_encode.out \
    ../src/utils.sv \
    ../src/posit_encode.sv && ./posit_encode.out

    iverilog -g2012 -DTEST_BENCH_ENCODE               -DN=16 -DES=1 -o posit_encode.out \
    ../src/utils.sv \
    ../src/posit_encode.sv && ./posit_encode.out

    yosys -p "synth_intel -family max10 -top posit_encode -vqm posit_encode.vqm" \
    ../src/utils.sv \
    ../src/posit_encode.sv > yosys_posit_encode.out

*/
module posit_encode #(
        parameter N = `N,
        parameter ES = `ES
    )(
        input          is_zero,
        input          is_nan,

        input sign,
        input [K_SIZE-1:0] k,
        input [ES-1:0] exp,
        input [MANT_SIZE-1:0] mant,
        output [N-1:0] posit
    );

    function [N-1:0] c2(input [N-1:0] a);
        c2 = ~a + 1'b1;
    endfunction

    function is_negative(input [S:0] k);
        is_negative = k[S];
    endfunction

    function [N-1:0] shl (
            input [N-1:0] bits,
            input [N-1:0] rhs
        );
        shl = rhs[N-1] == 0 ? bits << rhs : bits >> c2(rhs);
    endfunction


    wire [REG_LEN_SIZE-1:0] reg_len;
    assign reg_len = $signed(k) >= 0 ? k + 2 : -$signed(k) + 1;



    wire [N-1:0] bits_assembled;

    wire [N:0] regime_bits; // 1 bit longer than it could regularly fit in.
    
    assign regime_bits = is_negative(k) ? 1 : (shl(1, (k + 1)) - 1) << 1;


`ifndef NO_ES_FIELD
`else
    wire exp;
    assign exp = 0;
`endif

    assign bits_assembled = ( 
          shl(sign, N-1)
        + shl(regime_bits, N - 1 - reg_len)

        + shl(exp, N - 1 - reg_len - ES)

        + mant
    );

    wire [N-1:0] bits;
    assign bits = 
        sign == 0 ? bits_assembled : 
                    c2(bits_assembled & ~(1 << (N - 1)));

    /*
    ~(1'b1 << (N-1)) === {1'b0, {N-1{1'b1}}}
    */

    assign posit = 
        is_zero === 1 ? 0 : 
        is_nan  === 1 ? (1 << (N-1)) :
                        bits;
            /*  ^^^ 3 equal signs needed to compare against 1'bx, 
                otherwise if `is_zero` or `is_nan` == 1'bx, also 
                `posit` would be 'bX, regardless. */
endmodule


`ifdef TEST_BENCH_ENCODE 

// defaulted to P<8,0> unless specified via some `-D`efine.

module tb_posit_encode;
    function [N-1:0] c2(input [N-1:0] a);
        c2 = ~a + 1'b1;
    endfunction
    function [N-1:0] abs(input [N-1:0] in);
        abs = in[N-1] == 0 ? in : c2(in);
    endfunction

    parameter N = `N;
    parameter ES = `ES;

    /* inputs */
    reg            is_zero;
    reg            is_nan;

    reg sign;
    reg [REG_LEN_SIZE-1:0] reg_len;
    reg [K_SIZE-1:0] k;
    reg [ES-1:0] exp;
    reg [MANT_SIZE-1:0] mant;
    
    /* output */
    wire [N-1:0]    posit;
    /*************************/

    reg [N-1:0]   posit_expected;
    reg err;
    
    reg [N:0] test_no;

    posit_encode #(
        .N(N),
        .ES(ES)
    ) posit_encode_inst (
        .is_zero(is_zero),
        .is_nan(is_nan),

        .sign(sign),
        .reg_len(reg_len),
        .k(k),
        .exp(exp),
        .mant(mant),
        .posit(posit)
    );

    

    always @(*) begin
        err = posit == posit_expected ? 0 : 1'bx;
    end

    initial begin
             if (N == 8 && ES == 0) $dumpfile("tb_posit_encode_P8E0.vcd");
        else if (N == 5 && ES == 1) $dumpfile("tb_posit_encode_P5E1.vcd");
        else if (N == 16 && ES == 1) $dumpfile("tb_posit_encode_P16E1.vcd");
        else                        $dumpfile("tb_posit_encode.vcd");

	    $dumpvars(0, tb_posit_encode);                        
            
        if (N == 8 && ES == 0) begin
            `include "../test_vectors/tv_posit_encode_P8E0.sv"
        end

        if (N == 16 && ES == 1) begin
            `include "../test_vectors/tv_posit_encode_P16E1.sv"
        end
       

        #10;
		$finish;
    end

endmodule
`endif
