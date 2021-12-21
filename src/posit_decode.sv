/*
Description:
    Posit decoder.

Usage:
    cd $PROJECT_ROOT/waveforms

    iverilog -DTEST_BENCH_DECODE -DNO_ES_FIELD -DN=8 -DES=0 -o posit_decode.out \
    ../src/posit_decode.sv \
    ../src/highest_set.sv \
    ../src/cls.sv \
    && ./posit_decode.out

    iverilog -DTEST_BENCH_DECODE               -DN=16 -DES=1 -o posit_decode.out \
    ../src/posit_decode.sv \
    ../src/highest_set.sv \
    ../src/cls.sv \
    && ./posit_decode.out

    iverilog -DTEST_BENCH_DECODE               -DN=32 -DES=2 -o posit_decode.out \
    ../src/posit_decode.sv \
    ../src/highest_set.sv \
    ../src/cls.sv \
    && ./posit_decode.out


    yosys -p "synth_intel -family max10 -top posit_decode -vqm posit_decode.vqm" \
    ../src/posit_decode.sv \
    ../src/highest_set.sv \
    ../src/cls.sv > yosys_posit_decode.out

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
        output [S:0]    reg_len,
        
        output [S:0]    k,
`ifndef NO_ES_FIELD
        output [ES-1:0] exp,
`endif
        output [N-1:0]  mant
    );

    function [N-1:0] c2(input [N-1:0] a);
        c2 = ~a + 1'b1;
    endfunction

    // function [N-1:0] min(input [N-1:0] a, b);
    //     min = a < b ? a : b;
    // endfunction

    assign is_zero = bits == {N{1'b0}};
    assign is_inf = bits == {1'b1, {N-1{1'b0}}};
    assign sign = bits[N-1];
    
    wire [N-1:0] u_bits;
    assign u_bits = sign == 0 ? bits : c2(bits);

    wire [S-1:0] leading_ones, leading_zeros;

    // regime sign
    assign reg_s = u_bits[N-2];

    assign k = reg_s == 1 ? leading_ones - 1 : c2(leading_zeros);
    
    assign reg_len = reg_s == 1 ? k + 2 : c2(k) + 1;

    // // not useful but anyway

`ifndef NO_ES_FIELD
    assign exp = (u_bits << (1 + reg_len)) >> (N - ES);
`endif

    wire [S:0] mant_len;
    assign mant_len = N - 1 - reg_len - ES;


    assign mant = (u_bits << (N - mant_len)) >> (N - mant_len);
    
    
    // count leading X
    cls #(
        .N(N),
        .S(S)
    ) clo_inst_o (
        .bits               (u_bits << 1), // strip sign bit and count ones from the left
        .leading_ones       (leading_ones),
        .index_highest_set  ()
    );
    cls #(
        .N(N),
        .S(S)
    ) clo_inst_z (
        .bits               (~u_bits << 1), // flip bits, strip sign bit and count zeros from the left
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

    /* input */
    reg [N-1:0]     bits;
    /* outputs */
    wire            is_zero;
    wire            is_inf;
    wire            sign;
    wire            reg_s;
    wire [S  :0]    reg_len;
    wire [S  :0]    k;
`ifndef NO_ES_FIELD
    wire [ES-1:0]   exp;
`endif
    wire [N-1:0]    mant;
    /*************************/

    reg sign_expected, reg_s_expected;
    reg [S  :0] reg_len_expected, k_expected;
    reg [ES-1:0] exp_expected;
    reg [N-1:0] mant_expected;
    reg [S-1:0] mant_len_expected;
    reg is_zero_expected, is_inf_expected;
    reg err;

    reg [N:0] test_no;

`ifndef NO_ES_FIELD
    reg diff_exp;
`endif    
    reg diff_k, diff_mant, diff_is_zero, diff_is_inf;
    
    reg k_is_pos;
    
    always @(*) begin
`ifndef NO_ES_FIELD
        diff_exp = (exp === exp_expected ? 0 : 'bx);
`endif
        diff_mant = (mant === mant_expected ? 0 : 'bx);
        diff_k = (k === k_expected ? 0 : 'bx);
        diff_is_zero = (is_zero === is_zero_expected ? 0 : 'bx);
        diff_is_inf = (is_inf === is_inf_expected ? 0 : 'bx);
        
        if (
            diff_mant == 0
`ifndef NO_ES_FIELD
            && diff_exp == 0 
`endif
            && diff_k == 0 
            && diff_is_zero == 0 
            && diff_is_inf == 0
        ) err = 0;
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

        .reg_len        (reg_len),
        .k              (k),
`ifndef NO_ES_FIELD
        .exp            (exp),
`endif
        .mant           (mant)
    );

    initial begin
             if (N == 8 && ES == 0) $dumpfile("tb_posit_decode_P8E0.vcd");
        else if (N == 5 && ES == 1) $dumpfile("tb_posit_decode_P5E1.vcd");
        else if (N == 16 && ES == 1)$dumpfile("tb_posit_decode_P16E1.vcd");
        else if (N == 32 && ES == 2)$dumpfile("tb_posit_decode_P32E2.vcd");
        else                        $dumpfile("tb_posit_decode.vcd");

	    $dumpvars(0, tb_posit_decode);                        
            
        if (N == 8 && ES == 0) begin
            `include "../src/tb_posit_decode_P8E0.sv"
        end

        if (N == 5 && ES == 1) begin
            `include "../src/tb_posit_decode_P5E1.sv"
        end

        if (N == 16 && ES == 1) begin
            `include "../src/tb_posit_decode_P16E1.sv"
        end

        if (N == 32 && ES == 2) begin
            `include "../src/tb_posit_decode_P32E2.sv"
        end


        
        #10;
		$finish;
    end

endmodule
`endif



