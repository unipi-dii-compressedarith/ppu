/*

Description:
    Posit encoder.

Usage:
    cd $PROJECT_ROOT/waveforms
    
    iverilog -DTEST_BENCH_ENCODE -DNO_ES_FIELD -DN=8 -DES=0 -o posit_encode.out ../src/posit_encode.sv && ./posit_encode.out

    iverilog -DTEST_BENCH_ENCODE               -DN=16 -DES=1 -o posit_encode.out ../src/posit_encode.sv && ./posit_encode.out

    yosys -p "synth_intel -family max10 -top posit_encode -vqm posit_encode.vqm" ../src/posit_encode.sv > yosys_posit_encode.out

*/
module posit_encode #(
        parameter N = 8,
        parameter ES = 0
    )(
        input          is_zero,
        input          is_inf,
        input [(
              1             // sign
            + $clog2(N) + 1 // reg_len
            + $clog2(N) + 1 // k
`ifndef NO_ES_FIELD
            + ES            // exp
`endif
            + N             // mant
        ) - 1:0]        encode_in,
        output [N-1:0] posit
    );
    
    localparam S = $clog2(N);


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

    wire          sign;
    wire [$clog2(N):0]    reg_len;
    wire [$clog2(N):0]    k;
`ifndef NO_ES_FIELD
    wire [ES-1:0] exp;
`endif
    wire [N-1:0]  mant;

    assign {
        sign, 
        reg_len, 
        k, 
`ifndef NO_ES_FIELD
        exp,
`endif
        mant
    } = encode_in;


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
        + shl(regime_bits, N-1-reg_len)

        + shl(exp, N-1-reg_len-ES)

        + mant
    );

    wire [N-1:0] bits;
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

// defaulted to P<8,0> unless specified via some `-D`efine.

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

    /* inputs */
    reg            is_zero;
    reg            is_inf;

    reg [(
          1             // sign
        + $clog2(N) + 1 // reg_len
        + $clog2(N) + 1 // k
`ifndef NO_ES_FIELD
        + ES            // exp
`endif
        + N             // mant
    ) - 1:0]        encode_in;

    reg             sign;
    reg [S:0]       reg_len;
    reg [S:0]       k;
`ifndef NO_ES_FIELD
    reg [ES-1:0]    exp;
`endif
    reg [N-1:0]     mant;
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
        .is_zero        (is_zero),
        .is_inf         (is_inf),
        .encode_in      (encode_in),
        .posit          (posit)
    );

    always @(*) begin
        encode_in = {
            sign, 
            reg_len, 
            k, 
`ifndef NO_ES_FIELD
            exp,
`endif
            mant
        };
    end

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
