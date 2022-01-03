/*
Description:
    Posit decoder.

Usage:
    cd $PROJECT_ROOT/waveforms

    iverilog -g2012 -DTEST_BENCH_DECODE -DNO_ES_FIELD -DN=8 -DES=0 -o posit_decode.out \
    ../src/posit_decode.sv \
    ../src/utils.sv \
    ../src/highest_set.sv \
    ../src/cls.sv \
    && ./posit_decode.out

    iverilog -g2012 -DTEST_BENCH_DECODE               -DN=16 -DES=1 -o posit_decode.out \
    ../src/posit_decode.sv \
    ../src/utils.sv \
    ../src/highest_set.sv \
    ../src/cls.sv \
    && ./posit_decode.out

    iverilog -g2012 -DTEST_BENCH_DECODE               -DN=32 -DES=2 -o posit_decode.out \
    ../src/posit_decode.sv \
    ../src/utils.sv \
    ../src/highest_set.sv \
    ../src/cls.sv \
    && ./posit_decode.out

    sv2v -DN=16 -DES=1 \
    ../src/posit_decode.sv \
    ../src/utils.sv \
    ../src/highest_set.sv \
    ../src/cls.sv > posit_decode.v

    yosys -p "synth_intel -family max10 -top posit_decode -vqm posit_decode.vqm" \
    ../src/posit_decode.sv \
    ../src/utils.sv \
    ../src/highest_set.sv \
    ../src/cls.sv > yosys_posit_decode.out

*/
module posit_decode #(
        parameter N = `N,    // specified in `utils.sv`
        parameter ES = `ES   // specified in `utils.sv`
    )(
        input [N-1:0]   bits,
        output [DECODE_OUTPUT_SIZE-1:0] decode_out,
        output [1:0]    is_special
    );

    wire is_zero, is_nan;
    assign is_special = {is_zero, is_nan};

    wire sign, reg_s;
    wire [S:0] reg_len, k;
`ifndef NO_ES_FIELD
    wire [ES-1:0] exp;
`endif
    wire [N-1:0] mant;

    function [N-1:0] c2(input [N-1:0] a);
        c2 = ~a + 1'b1;
    endfunction

    assign is_zero = bits == {N{1'b0}};
    assign is_nan = bits == {1'b1, {N-1{1'b0}}};
    assign sign = bits[N-1];
    
    // u_bits = abs(bits)  
    wire [N-1:0] u_bits;
    assign u_bits = sign == 0 ? bits : c2(bits);

    wire [S-1:0] leading_set;

    // regime sign
    assign reg_s = u_bits[N-2];

    assign k = reg_s == 1 ? leading_set - 1 : c2(leading_set);
    
    assign reg_len = reg_s == 1 ? k + 2 : c2(k) + 1;


`ifndef NO_ES_FIELD
    assign exp = (u_bits << (1 + reg_len)) >> (N - ES);
`endif

    wire [S:0] mant_len;
    assign mant_len = N - 1 - reg_len - ES;


    assign mant = (u_bits << (N - mant_len)) >> (N - mant_len);
    
    wire [N-1:0] bits_cls_in = sign == 0 ? u_bits : ~u_bits;
    
    wire val = bits_cls_in[N-2];

    // count leading X
    cls #(
        .N(N)
    ) clo_inst (
        .posit              (bits_cls_in), // strip sign bit and count ones from the left
        .val                (val),
        .leading_set        (leading_set),
        .index_highest_set  ()
    );

    // cls #(
    //     .N(N)
    // ) clo_inst_z (
    //     .bits               (~u_bits << 1), // flip bits, strip sign bit and count zeros from the left
    //     .leading_ones       (leading_zeros),
    //     .index_highest_set  ()
    // );

    decode_out decode_out_inst (
        .sign(sign),
        .reg_s(reg_s),
        .reg_len(reg_len),
        .k(k),
`ifndef NO_ES_FIELD
        .exp(exp),
`endif
        .mant(mant),
        .decode_out(decode_out)
    );

endmodule

module decode_out (
        input sign,
        input reg_s,
        input [S:0] reg_len,
        input [S:0] k,
`ifndef NO_ES_FIELD
        input [ES-1:0] exp,
`endif
        input [N-1:0] mant,
        output [DECODE_OUTPUT_SIZE-1:0] decode_out
    );
    assign decode_out = {
        sign, 
        reg_s, 
        reg_len, 
        k, 
`ifndef NO_ES_FIELD 
        exp, 
`endif        
        mant
    };
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
    $display("missing N");
`endif

`ifdef ES
    parameter ES = `ES;
`else
    $display("missing ES");
`endif  
    


    // input
    reg [N-1:0]     bits;
    
    // outputs
    reg [DECODE_OUTPUT_SIZE-1:0] decode_out;
    wire [1:0]      is_special;
    /*************************/

    reg sign;
    reg reg_s;
    reg [S:0] reg_len, k;
`ifndef NO_ES_FIELD
    reg [ES-1:0] exp;
`endif
    reg [N-1:0] mant;

    reg             sign_expected;
    reg             reg_s_expected;
    reg [S:0]       reg_len_expected, k_expected;
`ifndef NO_ES_FIELD
    reg [ES-1:0]    exp_expected;
`endif
    reg [N-1:0]     mant_expected;
    reg [S-1:0]     mant_len_expected;
    reg             is_special_expected;
    
    reg err;
    reg [N:0] test_no;


`ifndef NO_ES_FIELD
    reg diff_exp;
`endif    
    reg diff_k, diff_mant, diff_is_special, diff_sign;
    
    reg k_is_pos;

    // unpacking `decode_out` into its fundamental signals in order to be compared with the expected values.
    always @(*) begin
        {
            sign,
            reg_s,
            reg_len,
            k,
`ifndef NO_ES_FIELD
            exp,
`endif
            mant
        } = decode_out;
    end


    
    always @(*) begin
`ifndef NO_ES_FIELD
        diff_exp = (exp === exp_expected ? 0 : 'bx);
`endif
        diff_mant = (mant === mant_expected ? 0 : 'bx);
        diff_k = (k === k_expected ? 0 : 'bx);
        diff_is_special = (is_special === is_special_expected ? 0 : 'bx);
        diff_sign = (sign === sign_expected ? 0 : 'bx);
        
        if (
            diff_mant == 0
`ifndef NO_ES_FIELD
            && diff_exp == 0 
`endif
            && diff_sign == 0
            && diff_k == 0 
            && diff_is_special == 0 
        ) err = 0;
        else err = 1'bx;
    end

    posit_decode #(
        .N(N),
        .ES(ES)
    ) posit_decode_inst (
        .bits           (bits),
        .decode_out     (decode_out),
        .is_special     (is_special)
    );

    initial begin
             if (N == 8 && ES == 0) $dumpfile("tb_posit_decode_P8E0.vcd");
        else if (N == 5 && ES == 1) $dumpfile("tb_posit_decode_P5E1.vcd");
        else if (N == 16 && ES == 1)$dumpfile("tb_posit_decode_P16E1.vcd");
        else if (N == 32 && ES == 2)$dumpfile("tb_posit_decode_P32E2.vcd");
        else                        $dumpfile("tb_posit_decode.vcd");

	    $dumpvars(0, tb_posit_decode);                        
            
        if (N == 8 && ES == 0) begin
            `include "../test_vectors/tv_posit_decode_P8E0.sv"
        end

        if (N == 5 && ES == 1) begin
            `include "../test_vectors/tv_posit_decode_P5E1.sv"
        end

        if (N == 16 && ES == 1) begin
            `include "../test_vectors/tv_posit_decode_P16E1.sv"
        end

        if (N == 32 && ES == 2) begin
            `include "../test_vectors/tv_posit_decode_P32E2.sv"
        end


        
        #10;
		$finish;
    end

endmodule
`endif



