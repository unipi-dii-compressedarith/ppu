/*
iverilog -DTEST_BENCH_MUL mul.sv && ./a.out


TODO: get rid of unnecessary flags
*/
module mul #(
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
        input  [ES-1:0] p1_exp,
        input  [N-1:0]  p1_mant,

        input           p2_is_zero,
        input           p2_is_inf,
        input           p2_sign,
        input           p2_reg_s,
        input  [N-1:0]  p2_regime_bits,
        input  [S-1:0]  p2_reg_len,
        input  [N-1:0]  p2_k,
        input  [ES-1:0] p2_exp,
        input  [N-1:0]  p2_mant,

        output          pout_is_zero,
        output          pout_is_inf,
        output          pout_sign,
        output          pout_reg_s,
        output [N-1:0]  pout_regime_bits,
        output [S-1:0]  pout_reg_len,
        output [N-1:0]  pout_k,
        output [ES-1:0] pout_exp,
        output [N-1:0]  pout_mant
    );


    assign pout_is_zero = p1_is_zero || p2_is_zero;
    assign pout_is_inf = (!p1_is_zero && p2_is_inf) || (p1_is_inf && !p2_is_zero);      // ...missing something?

    assign pout_sign = p1_sign ^ p2_sign;
    
    wire [2*N-1:0] prod_mantissae, prod_mantissae_adjusted;
    assign prod_mantissae = p1_mant * p2_mant;

    wire carry;
    assign carry = prod_mantissae[2*N-1];
    assign prod_mantissae_adjusted = carry == 1 ? prod_mantissae >> 1 : prod_mantissae;

    assign k = carry == 1 ? (1 + p1_k + p2_k) : (p1_k + p2_k);



endmodule


`ifdef TEST_BENCH_MUL
module tb_mul;

    parameter N = 8;
    parameter S = $clog2(N);
    parameter ES = 0;
    reg            p1_is_zero;
    reg            p1_is_inf;
    reg            p1_sign;
    reg            p1_reg_s;
    reg   [N-1:0]  p1_regime_bits;
    reg   [S-1:0]  p1_reg_len;
    reg   [N-1:0]  p1_k;
    reg   [ES-1:0] p1_exp;
    reg   [N-1:0]  p1_mant;

    reg            p2_is_zero;
    reg            p2_is_inf;
    reg            p2_sign;
    reg            p2_reg_s;
    reg   [N-1:0]  p2_regime_bits;
    reg   [S-1:0]  p2_reg_len;
    reg   [N-1:0]  p2_k;
    reg   [ES-1:0] p2_exp;
    reg   [N-1:0]  p2_mant;

    wire           pout_is_zero;
    wire           pout_is_inf;
    wire           pout_sign;
    wire           pout_reg_s;
    wire  [N-1:0]  pout_regime_bits;
    wire  [S-1:0]  pout_reg_len;
    wire  [N-1:0]  pout_k;
    wire  [ES-1:0] pout_exp;
    wire  [N-1:0]  pout_mant;


    mul #(
        .N                  (N),
        .S                  (S),
        .ES                 (ES)
    ) mul_inst (  
        .p1_is_zero         (p1_is_zero),   
        .p1_is_inf          (p1_is_inf), 
        .p1_sign            (p1_sign), 
        .p1_reg_s           (p1_reg_s),
        .p1_regime_bits     (p1_regime_bits),
        .p1_reg_len         (p1_reg_len),
        .p1_k               (p1_k),
        .p1_exp             (p1_exp),
        .p1_mant            (p1_mant),
    
        .p2_is_zero         (p2_is_zero), 
        .p2_is_inf          (p2_is_inf),   
        .p2_sign            (p2_sign),   
        .p2_reg_s           (p2_reg_s),
        .p2_regime_bits     (p2_regime_bits),
        .p2_reg_len         (p2_reg_len),
        .p2_k               (p2_k),
        .p2_exp             (p2_exp),    
        .p2_mant            (p2_mant),

        .pout_is_zero       (pout_is_zero),
        .pout_is_inf        (pout_is_inf),
        .pout_sign          (pout_sign),
        .pout_reg_s         (pout_reg_s),
        .pout_regime_bits   (pout_regime_bits),
        .pout_reg_len       (pout_reg_len),
        .pout_k             (pout_k),
        .pout_exp           (pout_exp),
        .pout_mant          (pout_mant)
    );


    initial begin
        
             if (N == 8 && ES == 0) $dumpfile("tb_mul_P8E0.vcd");
        else if (N == 5 && ES == 1) $dumpfile("tb_mul_P5E1.vcd");
        else                        $dumpfile("tb_mul.vcd");

	    $dumpvars(0, tb_mul);                        
            
        if (N == 8 && ES == 0) begin
        

            p1_is_zero = 0;
            p1_is_inf = 0;
            p1_sign = 0;
            p1_reg_s = 1;
            p1_regime_bits = 8'b00000010;
            p1_reg_len = 2;
            p1_k = 1;
            p1_exp = 0;
            p1_mant = 0;
            p2_is_zero = 0; 
            p2_is_inf = 0;
            p2_sign = 0;
            p2_reg_s = 1;
            p2_regime_bits = 8'b00000110;
            p2_reg_len = 3;
            p2_k = 2;
            p2_exp = 0;
            p2_mant = 1;


        end


        #10;
    end

endmodule
`endif