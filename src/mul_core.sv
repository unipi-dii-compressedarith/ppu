/*

iverilog -DTEST_BENCH_MUL_CORE -DNO_ES_FIELD -DN=8 -DES=0  -o mul_core.out ../src/mul_core.sv && ./mul_core.out

iverilog -DTEST_BENCH_MUL_CORE               -DN=16 -DES=1 -o mul_core.out ../src/mul_core.sv && ./mul_core.out

iverilog -DTEST_BENCH_MUL_CORE               -DN=32 -DES=2 -o mul_core.out ../src/mul_core.sv && ./mul_core.out

yosys -p "synth_intel -family max10 -top mul_core -vqm mul_core.vqm" \
    ../src/mul_core.sv > yosys_mul_core.out

TODO: get rid of unnecessary flags
*/
module mul_core #(
        parameter N = 8,
        parameter ES = 0
    )(
        input           p1_is_zero,
        input           p1_is_inf,
        
        input [(
              1             // sign
            + 1             // reg_s
            + $clog2(N)     // reg_len
            + $clog2(N)     // k
`ifndef NO_ES_FIELD
            +ES             // exponent
`endif
            +N              // mantissa
        ) - 1:0]        p1_decode_out,


        input           p2_is_zero,
        input           p2_is_inf,
        input [(
              1             // sign
            + 1             // reg_s
            + $clog2(N)     // reg_len
            + $clog2(N)     // k
`ifndef NO_ES_FIELD
            +ES             // exponent
`endif
            +N              // mantissa
        ) - 1:0]        p2_decode_out,


        output          pout_is_zero,
        output          pout_is_inf,
        output          pout_sign,
        output [$clog2(N):0]    pout_reg_len,
        output [$clog2(N):0]    pout_k,
`ifndef NO_ES_FIELD
        output [ES-1:0] pout_exp,
`endif
        output [N-1:0]  pout_mant
    );

    localparam S = $clog2(N);

    wire            p1_sign, p2_sign;
    wire            p1_reg_s, p2_reg_s;
    wire [S:0]      p1_reg_len, p2_reg_len;
    wire [S:0]      p1_k, p2_k;
`ifndef NO_ES_FIELD
    wire [ES-1:0]   p1_exp, p2_exp;
`endif
    wire [N-1:0]    p1_mant, p2_mant;

    assign {
        p1_sign,
        p1_reg_s,
        p1_reg_len,
        p1_k,
`ifndef NO_ES_FIELD
        p1_exp,
`endif
        p1_mant
    } = p1_decode_out;
    assign {
        p2_sign,
        p2_reg_s,
        p2_reg_len,
        p2_k,
`ifndef NO_ES_FIELD
        p2_exp,
`endif
        p2_mant
    } = p2_decode_out;


    function [N-1:0] min(
            input [N-1:0] a, b
        );
        min = a <= b ? a : b;
    endfunction

    function [N-1:0] max(
            input [N-1:0] a, b
        );
        max = a >= b ? a : b;
    endfunction

    function [N-1:0] c2(input [N-1:0] a);
        c2 = ~a + 1'b1;
    endfunction

    parameter MSB = 1 << (N - 1);

    assign pout_is_zero = p1_is_zero || p2_is_zero;
    assign pout_is_inf = (p2_is_inf) || (p1_is_inf);

    wire [S:0] _k_1, _k_2, _k_3, _k_4;
    assign _k_1 = p1_k + p2_k;


    wire [ES:0] _exp_1, _exp_2, _exp_3, _exp_4;
`ifndef NO_ES_FIELD
    assign _exp_1 = p1_exp + p2_exp;
`else
    assign _exp_1 = 0;
`endif

    
    wire [S:0] F1, F2; // mantissae field size
    assign F1 = N - 1 - p1_reg_len - ES;
    assign F2 = N - 1 - p2_reg_len - ES;
    
    wire [N-1:0] f1, f2; // mantissae fields, left aligned (N bits)
    assign f1 = MSB | p1_mant << (N - 1 - F1);
    assign f2 = MSB | p2_mant << (N - 1 - F2);


    wire [2*N-1:0] _mant_1, _mant_2;
    assign _mant_1 = f1 * f2;

    wire mant_carry;
    assign mant_carry = _mant_1[2*N - 1];


    wire _exp_carry_1, _exp_carry_2;
    assign _exp_carry_1 = _exp_1[ES];


    assign _k_2 = _exp_carry_1 == 1 ? _k_1 + 1 : _k_1;

    assign _exp_2 = 
`ifndef NO_ES_FIELD
        _exp_carry_1 == 1 ? _exp_1 & {ES{1'b1}} : _exp_1;
`else
        _exp_1;
`endif


    assign _exp_3 = mant_carry == 1 ? _exp_2 + 1 : _exp_2;
    
    assign _exp_carry_2 = _exp_3[ES];


    assign _k_3 = mant_carry == 1 ? 
        (_exp_carry_2 == 1 ? _k_2 + 1 : _k_2) : _k_2;


    assign _exp_4 = 
`ifndef NO_ES_FIELD
    _exp_carry_2 == 1 ? _exp_3 & {ES{1'b1}} : _exp_3;
`else
    _exp_3;
`endif


    assign _mant_2 = mant_carry == 1 ? _mant_1 >> 1 : _mant_1;


    wire k_is_oob;

    assign k_is_oob = (
           $signed(_k_3) > $signed(  N - 2 ) 
        || $signed(_k_3) < $signed(-(N - 2))
        ) ? 1 : 0;


    assign _k_4 = 
        ($signed(_k_3) >  $signed(  N - 2)) ? N - 2 : 
        ($signed(_k_3) >= $signed(-(N - 2)) && ($signed(_k_3) <= $signed(N - 2))) ? _k_3 : 
        ($signed(_k_3) <  $signed(-(N - 2))) ? -(N - 2) : 
        'bz;

    
    wire [S:0] reg_len;
    assign reg_len = $signed(_k_4) >= 0 ? _k_4 + 2 : c2(_k_4) + 1;

    wire [S:0] mant_len;
    assign mant_len = $signed(N - 1 - reg_len - ES);

    wire [(2*N)-1:0] _mant_fractional_part_left_1;
    assign _mant_fractional_part_left_1 = _mant_2 & {2*N-2{1'b1}};
    
    wire [N-1:0] mant_fractional_part_left;
    assign mant_fractional_part_left = _mant_fractional_part_left_1 >> (2*N - mant_len - 2);

    assign pout_sign = p1_sign ^ p2_sign;
    
    assign pout_reg_len = reg_len;
    
    assign pout_k = _k_4;

`ifndef NO_ES_FIELD
    assign pout_exp = _exp_4;
`endif

    assign pout_mant = mant_fractional_part_left;

endmodule





`ifdef TEST_BENCH_MUL_CORE
module tb_mul_core;
    
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
    // parameter S2 = 1 + 1 + S + S + ES + N;

`ifdef ES
    parameter ES = `ES;
`else
    parameter ES = 0;
`endif  

    reg             p1_is_zero;
    reg             p1_is_inf;

    reg             p1_sign, p2_sign;
    reg [S:0]       p1_reg_len, p2_reg_len;
    reg [S:0]       p1_k, p2_k;
`ifndef NO_ES_FIELD
    reg [ES-1:0]    p1_exp, p2_exp;
`endif
    reg [N-1:0]     p1_mant, p2_mant;

    reg [(
          1             // sign
        + 1             // reg_s
        + $clog2(N)     // reg_len
        + $clog2(N)     // reg_len
`ifndef NO_ES_FIELD
        +ES             // exponent
`endif
        +N              // mantissa
    ) - 1:0]   p1_decode_out;

    reg            p2_is_zero;
    reg            p2_is_inf;
    reg [(
          1             // sign
        + 1             // reg_s
        + $clog2(N)     // reg_len
        + $clog2(N)     // reg_len
`ifndef NO_ES_FIELD
        +ES             // exponent
`endif
        +N              // mantissa
    ) - 1:0]   p2_decode_out;

    wire           pout_is_zero;
    wire           pout_is_inf;
    wire           pout_sign;
    wire  [S:0]    pout_reg_len;
    wire  [S:0]    pout_k;
`ifndef NO_ES_FIELD    
    wire  [ES-1:0] pout_exp;
`endif
    wire  [N-1:0]  pout_mant;

    reg            pout_is_zero_expected;
    reg            pout_is_inf_expected;
    reg            pout_sign_expected;
    reg   [S:0]    pout_reg_len_expected;
    reg   [S:0]    pout_k_expected;
`ifndef NO_ES_FIELD    
    reg   [ES-1:0] pout_exp_expected;
`endif
    reg   [N-1:0]  pout_mant_expected;

    reg [N:0] test_no;

    reg [N-1:0] p1_hex, p2_hex, pout_hex;

    reg diff_pout_is_zero;
    reg diff_pout_is_inf;
    reg diff_pout_sign;
    reg diff_pout_reg_len;
    reg diff_pout_k;
`ifndef NO_ES_FIELD
    reg diff_pout_exp;
`endif
    reg diff_pout_mant;
    reg pout_off_by_1;


    mul_core #(
        .N                  (N),
        .ES                 (ES)
    ) mul_core_inst (
        /************ inputs ************/
        .p1_is_zero         (p1_is_zero),   
        .p1_is_inf          (p1_is_inf), 
        .p1_decode_out   (p1_decode_out),
    

        .p2_is_zero         (p2_is_zero), 
        .p2_is_inf          (p2_is_inf),   
        .p2_decode_out   (p2_decode_out),
        
        /************ outputs ************/
        .pout_is_zero       (pout_is_zero),
        .pout_is_inf        (pout_is_inf),
        .pout_sign          (pout_sign),
        .pout_reg_len       (pout_reg_len),
        .pout_k             (pout_k),
`ifndef NO_ES_FIELD
        .pout_exp           (pout_exp),
`endif
        .pout_mant          (pout_mant)
    );

    always @(*) begin
        p1_decode_out = {
            p1_sign,
            p1_reg_len,
            p1_k,
`ifndef NO_ES_FIELD
            p1_exp,
`endif
            p1_mant
        };

        p2_decode_out = {
            p2_sign,
            p2_reg_len,
            p2_k,
`ifndef NO_ES_FIELD
            p2_exp,
`endif
            p2_mant
        };
    end

    
    always @(*) begin
        diff_pout_is_zero = pout_is_zero === pout_is_zero_expected ? 0 : 1'bx;
        diff_pout_is_inf = pout_is_inf === pout_is_inf_expected ? 0 : 1'bx;
        diff_pout_sign = pout_sign === pout_sign_expected ? 0 : 1'bx;
        diff_pout_reg_len = pout_reg_len === pout_reg_len_expected ? 0 : 1'bx;
        diff_pout_k = pout_k === pout_k_expected ? 0 : 1'bx;
`ifndef NO_ES_FIELD
        diff_pout_exp = pout_exp === pout_exp_expected ? 0 : 1'bx;
`endif
        diff_pout_mant = pout_mant === pout_mant_expected ? 0 : 1'bx;

        pout_off_by_1 = abs(pout_mant - pout_mant_expected) == 1 ? 1 : 0;
        
    end


    initial begin
        
             if (N == 8 && ES == 0) $dumpfile("tb_mul_core_P8E0.vcd");
        else if (N == 5 && ES == 1) $dumpfile("tb_mul_core_P5E1.vcd");
        else if (N == 16 && ES == 1)$dumpfile("tb_mul_core_P16E1.vcd");
        else if (N == 32 && ES == 2)$dumpfile("tb_mul_core_P32E2.vcd");
        else                        $dumpfile("tb_mul_core.vcd");

        $dumpvars(0, tb_mul_core);                        
            
        if (N == 8 && ES == 0) begin
            `include "../test_vectors/tv_posit_mul_core_P8E0.sv"
        end

        if (N == 16 && ES == 1) begin
            `include "../test_vectors/tv_posit_mul_core_P16E1.sv"
        end

        if (N == 32 && ES == 2) begin
            `include "../test_vectors/tv_posit_mul_core_P32E2.sv"
        end


        #10;
    end

endmodule
`endif
