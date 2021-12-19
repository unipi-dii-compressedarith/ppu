/*
## === ES: 0 ====#
iverilog -DTEST_BENCH_MUL_CORE -DNO_ES_FIELD ../src/mul_core.sv && ./a.out

## === ES: not 0 ====#
iverilog -DTEST_BENCH_MUL_CORE               ../src/mul_core.sv && ./a.out


TODO: get rid of unnecessary flags
*/
module mul_core #(
        parameter N = 8,
        parameter S = $clog2(N),
        parameter ES = 0
    )(
        input           p1_is_zero,
        input           p1_is_inf,
        input           p1_sign,
        input           p1_reg_s,
        input  [N-1:0]  p1_regime_bits,
        input  [S-1:0]  p1_reg_len,
        input  [N-1:0]  p1_k,
`ifndef NO_ES_FIELD
        input  [ES-1:0] p1_exp,
`endif
        input  [N-1:0]  p1_mant,

        input           p2_is_zero,
        input           p2_is_inf,
        input           p2_sign,
        input           p2_reg_s,
        input  [N-1:0]  p2_regime_bits,
        input  [S-1:0]  p2_reg_len,
        input  [N-1:0]  p2_k,
`ifndef NO_ES_FIELD        
        input  [ES-1:0] p2_exp,
`endif
        input  [N-1:0]  p2_mant,

        output          pout_is_zero,
        output          pout_is_inf,
        output          pout_sign,
        output          pout_reg_s,
        output [N-1:0]  pout_regime_bits,
        output [S-1:0]  pout_reg_len,
        output [N-1:0]  pout_k,
`ifndef NO_ES_FIELD
        output [ES-1:0] pout_exp,
`endif
        output [N-1:0]  pout_mant
    );

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

    parameter MSB = 1 << (N - 1);

    assign pout_is_zero = p1_is_zero || p2_is_zero;
    assign pout_is_inf = (!p1_is_zero && p2_is_inf) || (p1_is_inf && !p2_is_zero);      // ...missing something?

    wire [N-1:0] k, k_adjusted_I, k_adjusted_II, k_adjusted_III;
    assign k = p1_k + p2_k;

    wire [N-1:0] exp, exp_adjusted_I, exp_adjusted_II, exp_adjusted_III;                          // fix size later

`ifndef NO_ES_FIELD
    assign exp = p1_exp + p2_exp;
`else
    assign exp = 0;
`endif

    
    wire [S-1:0] F1, F2; // mantissae field size
    assign F1 = N - 1 - p1_reg_len - ES;
    assign F2 = N - 1 - p2_reg_len - ES;
    
    wire [N-1:0] f1, f2; // mantissae fields, left aligned (N bits)
    assign f1 = MSB | p1_mant << (N - 1 - F1);
    assign f2 = MSB | p2_mant << (N - 1 - F2);



    wire [2*N-1:0] prod_mantissae;
    assign prod_mantissae = f1 * f2;

    wire mant_carry;
    assign mant_carry = prod_mantissae[2*N-1];

    wire exp_carry, exp_carry_I;

`ifndef NO_ES_FIELD
    assign exp_carry = exp[ES];
`else
    assign exp_carry = 0;
`endif

    assign k_adjusted_I = exp_carry == 1 ? k + 1 : k;

    assign exp_adjusted_I = exp_carry == 1 ? 
`ifndef NO_ES_FIELD
    exp & {ES{1'b1}} 
`else
    exp
`endif 
    : exp;

    assign exp_adjusted_II = mant_carry == 1 ? exp_adjusted_I + 1 : exp_adjusted_I;
    
    assign exp_carry_I = 
`ifndef NO_ES_FIELD
    exp_adjusted_II[ES];
`else
    0;
`endif

    assign k_adjusted_II = exp_carry_I == 1 ? k_adjusted_I + 1 : k_adjusted_I;
    assign exp_adjusted_III = exp_carry_I == 1 ? 
`ifndef NO_ES_FIELD
    exp_adjusted_II & {ES{1'b1}} 
`else
    exp_adjusted_II
`endif
    : exp_adjusted_II;


    assign prod_mantissae_adjusted = mant_carry == 1 ? prod_mantissae >> 1 : prod_mantissae;


    // adjust k based of whether it (over|under)flows or not.
    assign k_adjusted_III = k_adjusted_II >= 0 ? min(k_adjusted_II,  (N - 2)) : 
                                                 max(k_adjusted_II, -(N - 2)) ;

    
    wire [S-1:0] reg_len;
    assign reg_len = k_adjusted_III >= 0 ? k_adjusted_III + 2 : -k_adjusted_III + 1; // not bound checked

    wire [N-1:0] mant_len;
    assign mant_len = N - 1 - ES - reg_len;

    wire [(2*N)-1:0] mant_fraction_only;
    assign mant_fraction_only = prod_mantissae_adjusted & {2*N-2{1'b1}};
    
    wire [N-1:0] final_mant;
    assign final_mant = mant_fraction_only >> (2*N - mant_len - 2);

    assign pout_is_zero = 0;
    assign pout_is_inf = 0;
    assign pout_sign = p1_sign ^ p2_sign;
    assign pout_reg_s = 0; /* dontcare */
    assign pout_regime_bits = 0; /* dontcare */
    assign pout_reg_len = 0; /* dontcare */
    assign pout_k = k_adjusted_III;
`ifndef NO_ES_FIELD
    assign pout_exp = exp_adjusted_III;
`endif
    assign pout_mant = final_mant;

endmodule





`ifdef TEST_BENCH_MUL_CORE
module tb_mul_core;

    parameter N = 8;
    parameter S = $clog2(N);
`ifndef NO_ES_FIELD
    parameter ES = 1; // whatever
`else
    parameter ES = 0; 
`endif

    reg            p1_is_zero;
    reg            p1_is_inf;
    reg            p1_sign;
    reg            p1_reg_s;
    reg   [N-1:0]  p1_regime_bits;
    reg   [S-1:0]  p1_reg_len;
    reg   [N-1:0]  p1_k;
`ifndef NO_ES_FIELD        
    reg   [ES-1:0] p1_exp;
`endif
    reg   [N-1:0]  p1_mant;

    reg            p2_is_zero;
    reg            p2_is_inf;
    reg            p2_sign;
    reg            p2_reg_s;
    reg   [N-1:0]  p2_regime_bits;
    reg   [S-1:0]  p2_reg_len;
    reg   [N-1:0]  p2_k;
`ifndef NO_ES_FIELD    
    reg   [ES-1:0] p2_exp;
`endif
    reg   [N-1:0]  p2_mant;

    wire           pout_is_zero;
    wire           pout_is_inf;
    wire           pout_sign;
    wire           pout_reg_s;
    wire  [N-1:0]  pout_regime_bits;
    wire  [S-1:0]  pout_reg_len;
    wire  [N-1:0]  pout_k;
`ifndef NO_ES_FIELD    
    wire  [ES-1:0] pout_exp;
`endif
    wire  [N-1:0]  pout_mant;


    mul_core #(
        .N                  (N),
        .S                  (S),
        .ES                 (ES)
    ) mul_core_inst (  
        .p1_is_zero         (p1_is_zero),   
        .p1_is_inf          (p1_is_inf), 
        .p1_sign            (p1_sign), 
        .p1_reg_s           (p1_reg_s),
        .p1_regime_bits     (p1_regime_bits),
        .p1_reg_len         (p1_reg_len),
        .p1_k               (p1_k),
`ifndef NO_ES_FIELD    
        .p1_exp             (p1_exp),
`endif
        .p1_mant            (p1_mant),
    
        .p2_is_zero         (p2_is_zero), 
        .p2_is_inf          (p2_is_inf),   
        .p2_sign            (p2_sign),   
        .p2_reg_s           (p2_reg_s),
        .p2_regime_bits     (p2_regime_bits),
        .p2_reg_len         (p2_reg_len),
        .p2_k               (p2_k),
`ifndef NO_ES_FIELD    
        .p2_exp             (p2_exp),
`endif
        .p2_mant            (p2_mant),

        .pout_is_zero       (pout_is_zero),
        .pout_is_inf        (pout_is_inf),
        .pout_sign          (pout_sign),
        .pout_reg_s         (pout_reg_s),
        .pout_regime_bits   (pout_regime_bits),
        .pout_reg_len       (pout_reg_len),
        .pout_k             (pout_k),
`ifndef NO_ES_FIELD
        .pout_exp           (pout_exp),
`endif
        .pout_mant          (pout_mant)
    );


    initial begin
        
             if (N == 8 && ES == 0) $dumpfile("tb_mul_core_P8E0.vcd");
        else if (N == 5 && ES == 1) $dumpfile("tb_mul_core_P5E1.vcd");
        else if (N == 16 && ES == 1)$dumpfile("tb_mul_core_P16E1.vcd");
        else                        $dumpfile("tb_mul_core.vcd");

        $dumpvars(0, tb_mul_core);                        
            
        if (N == 8 && ES == 0) begin
        
            // P<8,0>:          0b01100000   0x60    2.0
            p1_is_zero = 0;
            p1_is_inf = 0;
            p1_sign = 0;
            p1_reg_s = 1;
            p1_regime_bits = 8'b00000010;
            p1_reg_len = 2;
            p1_k = 1;
`ifndef NO_ES_FIELD   
            p1_exp = 0;
`endif
            p1_mant = 0;
            // P<8,0>:          0b01110001   0x71    4.5
            p2_is_zero = 0; 
            p2_is_inf = 0;
            p2_sign = 0;
            p2_reg_s = 1;
            p2_regime_bits = 8'b00000110;
            p2_reg_len = 3;
            p2_k = 2;
`ifndef NO_ES_FIELD   
            p2_exp = 0;
`endif
            p2_mant = 1;
            // expected:    8.0
        
        end

        #10;
    end

endmodule
`endif