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

/////////////
        output sign,
        output reg_s,
        output [REG_LEN_SIZE-1:0] reg_len,
        output [K_SIZE-1:0] k,
`ifndef NO_ES_FIELD
        output [ES-1:0] exp,
`endif
        output [MANT_SIZE-1:0] mant,
/////////////
        output [1:0]    is_special
    );

    wire is_zero, is_nan;
    assign is_special = {is_zero, is_nan};


    function [N-1:0] c2(input [N-1:0] a);
        c2 = ~a + 1'b1;
    endfunction

    assign is_zero = bits == {N{1'b0}};
    assign is_nan = bits == {1'b1, {N-1{1'b0}}};
    assign sign = bits[N-1];
    
    // u_bits = abs(bits)  
    wire [N-1:0] u_bits;
    assign u_bits = sign == 0 ? bits : c2(bits);

    wire [S-1:0] leading_set,
                 leading_set_2;

    // regime sign
    assign reg_s = u_bits[N-2];



        /*
            * Mon Jan  3 17:29:23 CET 2022
            * added this line to handle the only case in which the multiplier used to fail
            * (and other operations too since they depend on this module).
            * This is the case where the posit is of the type `0b1(zeroes)1`
        **/
        wire is_special_case;
        assign is_special_case = bits == { {1{1'b1}}, {N-2{1'b0}}, {1{1'b1}} };


        assign leading_set_2 = is_special_case ? (N-1) : leading_set; // temporary fix until you have 
                                                                    // the time to embed this in the 
                                                                    // general case (perhaps fixing cls.sv)

    assign k = reg_s == 1 ? leading_set_2 - 1 : c2(leading_set_2);
    
    
    assign reg_len = reg_s == 1 ? k + 2 : c2(k) + 1;


`ifndef NO_ES_FIELD
    assign exp = (u_bits << (1 + reg_len)) >> (N - ES);
`endif

    wire [(S+1)-1:0] mant_len;
    assign mant_len = N - 1 - reg_len - ES;

    wire [FRAC_SIZE-1:0] frac;
    assign frac = (u_bits << (N - mant_len)) >> (N - mant_len);


    parameter MSB = 1 << (N - 1);
    // assign mant = frac; // before
    assign mant = MSB | (frac << (N-mant_len-1)); // after -> 1.frac

    
    wire [N-1:0] bits_cls_in = sign == 0 ? u_bits : ~u_bits;
    
    wire val = bits_cls_in[N-2];

    // count leading X
    cls #(
        .N(N)
    ) cls_inst (
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
    

    wire [1:0]      is_special;
    /*************************/

    reg sign;
    reg reg_s;
    reg [REG_LEN_SIZE-1:0] reg_len;
    reg [K_SIZE-1:0] k;
`ifndef NO_ES_FIELD
    reg [ES-1:0] exp;
`endif
    reg [N-1:0] mant;

    reg             sign_expected;
    reg             reg_s_expected;
    reg [REG_LEN_SIZE-1:0] reg_len_expected;
    reg [K_SIZE-1:0] k_expected;
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
        
        .sign           (sign),
        .reg_s          (reg_s),
        .reg_len        (reg_len),
        .k              (k),
`ifndef NO_ES_FIELD
        .exp            (exp),
`endif
        .mant           (mant),
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



