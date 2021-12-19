/*

iverilog -DTEST_BENCH_MUL -DNO_ES_FIELD -DN=8 -DES=0  -o mul.out \
../src/mul.sv \
../src/mul_core.sv \
../src/posit_decode.sv \
../src/posit_encode.sv \
../src/cls.sv \
../src/highest_set.sv \
&& ./mul.out


iverilog -DTEST_BENCH_MUL              -DN=16 -DES=1  -o mul.out \
../src/mul.sv \
../src/mul_core.sv \
../src/posit_decode.sv \
../src/posit_encode.sv \
../src/cls.sv \
../src/highest_set.sv \
&& ./mul.out


yosys -p "synth_intel -family max10 -top mul -vqm mul.vqm" mul.sv mul_core.sv posit_decode.sv posit_encode.sv cls.sv highest_set.sv > mul_yosys_intel.out



*/
module mul #(
        parameter N = 8,
        parameter S = $clog2(N),
        parameter ES = 0
    )(
        input [N-1:0] p1, p2,
        output [N-1:0] pout
    );

    wire         p1_reg_s, p2_reg_s;
    wire [S-1:0] p1_reg_len, p2_reg_len;
    wire [N-1:0] p1_reg_bits, p2_reg_bits;
    wire [N-1:0] p1_k, p2_k;
    wire [ES-1:0] p1_exp, p2_exp;
    wire [N-1:0] p1_mant, p2_mant;


    posit_decode #(
        .N(N),
        .S(S),
        .ES(ES)
    ) posit_decode_p1 (
        .bits           (p1),
        .is_zero        ( ),
        .is_inf         ( ),
        .sign           (p1_sign),
        .reg_s          (p1_reg_s),
        .regime_bits    (p1_reg_bits),
        .reg_len        (p1_reg_len),
        .k              (p1_k),
        .exp            (p1_exp),
        .mant           (p1_mant)
    );

    posit_decode #(
        .N(N),
        .S(S),
        .ES(ES)
    ) posit_decode_p2 (
        .bits           (p2),
        .is_zero        ( ),
        .is_inf         ( ),
        .sign           (p2_sign),
        .reg_s          (p2_reg_s),
        .regime_bits    (p2_reg_bits),
        .reg_len        (p2_reg_len),
        .k              (p2_k),
        .exp            (p2_exp),
        .mant           (p2_mant)
    );

    mul_core #(
        .N                  (N),
        .S                  (S),
        .ES                 (ES)
    ) mul_core_inst (  
        .p1_is_zero         ( ),
        .p1_is_inf          ( ),
        .p1_sign            (p1_sign), 
        .p1_reg_s           (p1_reg_s),
        .p1_regime_bits     (p1_reg_bits),
        .p1_reg_len         (p1_reg_len),
        .p1_k               (p1_k),
`ifndef NO_ES_FIELD    
        .p1_exp             (p1_exp),
`endif
        .p1_mant            (p1_mant),
    
        .p2_is_zero         ( ), 
        .p2_is_inf          ( ),
        .p2_sign            (p2_sign),
        .p2_reg_s           (p2_reg_s),
        .p2_regime_bits     (p2_reg_bits),
        .p2_reg_len         (p2_reg_len),
        .p2_k               (p2_k),
`ifndef NO_ES_FIELD    
        .p2_exp             ( ),
`endif
        .p2_mant            ( ),

        .pout_is_zero       ( ),
        .pout_is_inf        ( ),
        .pout_sign          ( ),
        .pout_reg_s         ( ),
        .pout_regime_bits   ( ),
        .pout_reg_len       ( ),
        .pout_k             ( ),
`ifndef NO_ES_FIELD
        .pout_exp           (p2_exp),
`endif
        .pout_mant          (p2_mant)
    );

    posit_encode #(
        .N(N),
        .S(S),
        .ES(ES)
    ) posit_encode_inst (
        .is_zero        ( ),
        .is_inf         ( ),
        .sign           ( ),
        .reg_s          ( ),
        .regime_bits    ( ),
        .reg_len        ( ),
        .k              ( ),
        .exp            ( ),
        .mant           ( ),
        .posit          (pout)
    );


endmodule





`ifdef TEST_BENCH_MUL
module tb_mul;


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

    reg [N-1:0] p1, p2;
    wire [N-1:0] pout;

    reg [N-1:0] pout_expected;

    reg [N:0] test_no;

    mul #(
        .N      (N),
        .S      (S),
        .ES     (ES)
    ) mul_inst (  
        .p1     (p1),
        .p2     (p2),
        .pout   (pout)
    );


    initial begin
        
             if (N == 8 && ES == 0) $dumpfile("tb_mul_P8E0.vcd");
        else if (N == 5 && ES == 1) $dumpfile("tb_mul_P5E1.vcd");
        else if (N == 16 && ES == 1)$dumpfile("tb_mul_P16E1.vcd");
        else                        $dumpfile("tb_mul.vcd");

        $dumpvars(0, tb_mul);                        
            
        if (N == 8 && ES == 0) begin
            `include "../src/tb_posit_mul_P16E1.sv"
        end

        if (N == 16 && ES == 1) begin
            `include "../src/tb_posit_mul_P16E1.sv"
        end


        #10;
    end

endmodule
`endif