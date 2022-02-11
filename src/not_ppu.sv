/*

iverilog -g2012 -DTEST_BENCH_NOT_PPU              -DN=16 -DES=1  -o not_ppu.out \
../src/utils.sv \
../src/common.sv \
../src/not_ppu.sv \
../src/input_conditioning.sv \
../src/unpack_posit.sv \
../src/check_special.sv \
../src/handle_special.sv \
../src/total_exponent.sv \
../src/core_op.sv \
../src/core_add_sub.sv \
../src/core_add.sv \
../src/core_sub.sv \
../src/core_mul.sv \
../src/core_div.sv \
../src/fast_reciprocal.sv \
../src/reciprocal_approx.sv \
../src/newton_raphson.sv \
../src/shift_fields.sv \
../src/unpack_exponent.sv \
../src/compute_rounding.sv \
../src/posit_decode.sv \
../src/posit_encode.sv \
../src/cls.sv \
../src/round.sv \
../src/sign_decisor.sv \
../src/set_sign.sv \
../src/highest_set.sv \
&& ./not_ppu.out


sv2v             -DN=16 -DES=1  \
../src/utils.sv \
../src/common.sv \
../src/not_ppu.sv \
../src/input_conditioning.sv \
../src/unpack_posit.sv \
../src/check_special.sv \
../src/handle_special.sv \
../src/total_exponent.sv \
../src/core_op.sv \
../src/core_add_sub.sv \
../src/core_add.sv \
../src/core_sub.sv \
../src/core_mul.sv \
../src/core_div.sv \
../src/fast_reciprocal.sv \
../src/reciprocal_approx.sv \
../src/newton_raphson.sv \
../src/shift_fields.sv \
../src/unpack_exponent.sv \
../src/compute_rounding.sv \
../src/posit_decode.sv \
../src/posit_encode.sv \
../src/cls.sv \
../src/round.sv \
../src/sign_decisor.sv \
../src/set_sign.sv \
../src/highest_set.sv > ./not_ppu.v && iverilog not_ppu.v

*/

// `define N (16)
// `define ES (1)

// `ifdef ALTERA_RESERVED_QIS
// `define NO_ES_FIELD
// `endif


module not_ppu #(
        parameter N = `N,
        parameter ES = `ES
    )(
        input [N-1:0] p1,
        input [N-1:0] p2,
        input [OP_SIZE-1:0] op,
        /*
        00: +
        01: -
        10: *
        11: /
        */
        output [N-1:0] pout
    );
    
    function [N-1:0] c2(input [N-1:0] a);
        c2 = ~a + 1'b1;
    endfunction

    wire [K_SIZE-1:0] k1, k2;
    wire [ES-1:0] exp1, exp2;
    wire [MANT_SIZE-1:0] mant1, mant2;
    wire [2*MANT_SIZE-1:0] mant_out_core_op;
    wire [TE_SIZE-1:0] te1, te2, te_out_core_op;

    wire sign1, sign2;


    wire p1_is_special, p2_is_special;
    wire p1_is_zero, p2_is_zero;
    wire p1_is_nan, p2_is_nan;

    check_special #(
        .N(N)   
    ) check_special_1 (
        .bits_in(p1),
        .is_special(p1_is_special),
        .is_zero(p1_is_zero),
        .is_nan(p1_is_nan)
    );

    check_special #(
        .N(N)   
    ) check_special_2 (
        .bits_in(p2),
        .is_special(p2_is_special),
        .is_zero(p2_is_zero),
        .is_nan(p2_is_nan)
    );

    wire [N-1:0] pout_special;
    handle_special #(
        .N(N)
    ) handle_special_inst (
        .p1(p1),
        .p2(p2),
        .op(op),
        .p1_is_zero(p1_is_zero),
        .p2_is_zero(p2_is_zero),
        .p1_is_nan(p1_is_nan),
        .p2_is_nan(p2_is_nan),
        .pout(pout_special)
    );

    wire [N-1:0] p1_out_cond, p2_out_cond;
    input_conditioning #(
        .N(N)
    ) input_conditioning_inst (
        .p1_in(p1),
        .p2_in(p2),
        .op(op),
        .p1_out(p1_out_cond),
        .p2_out(p2_out_cond)
    );

    unpack_posit #(
        .N(N),
        .ES(ES)
    ) unpack_posit_1 (
        .bits(p1_out_cond),
        .sign(sign1),
        .k(k1),
        .exp(exp1),
        .mant(mant1)
    );

    unpack_posit #(
        .N(N),
        .ES(ES)
    ) unpack_posit_2 (
        .bits(p2_out_cond),
        .sign(sign2),
        .k(k2),
        .exp(exp2),
        .mant(mant2)
    );

    total_exponent #(
        .N(N),
        .ES(ES)
    ) total_exponent_1 (
        .k(k1),
        .exp(exp1),
        .total_exp(te1)
    );

    total_exponent #(
        .N(N),
        .ES(ES)
    ) total_exponent_2 (
        .k(k2),
        .exp(exp2),
        .total_exp(te2)
    );

    
    core_op #(
        .N(N)
    ) core_op_inst (
        .op(op),
        .te1(te1),
        .te2(te2),
        .mant1(mant1),
        .mant2(mant2),
        .have_opposite_sign(sign1 ^ sign2),
        .te_out(te_out_core_op),
        .mant_out(mant_out_core_op)
    );


    wire [(2)-1:0]mant_non_factional_size;
    assign mant_non_factional_size = op == MUL ? 2 : op == DIV ? 2 : 1; // only mul has value 2.


    wire [K_SIZE-1:0] k;
    wire [ES-1:0] next_exp;
    wire [MANT_SIZE-1:0] mant_downshifted;
    wire round_bit;
    wire sticky_bit;
    wire k_is_oob;
    wire non_zero_mant_field_size;

    shift_fields #(
        .N(N),
        .ES(ES)
    ) shift_fields_inst (
        .mant(mant_out_core_op),
        .total_exp(te_out_core_op),
        .mant_non_factional_size(mant_non_factional_size),
        
        .k(k),
        .next_exp(next_exp),
        .mant_downshifted(mant_downshifted),

        .round_bit(round_bit),
        .sticky_bit(sticky_bit),
        .k_is_oob(k_is_oob),
        .non_zero_mant_field_size(non_zero_mant_field_size)
    );


    wire [N-1:0] posit;
    
    posit_encode #(
        .N(N),
        .ES(ES)
    ) posit_encode_inst (
        .is_zero(),
        .is_nan(),
        .sign(1'b0),
        .k(k),
        .exp(next_exp),
        .mant(mant_downshifted),

        .posit(posit)
    );


    wire [N-1:0] posit_rounded;
    round #(
        .N(N)
    ) round_inst (
        .posit(posit),
        .round_bit(round_bit),
        .sticky_bit(sticky_bit),
        .k_is_oob(k_is_oob),
        .mant_field_size_not_null(non_zero_mant_field_size),
        
        .posit_rounded(posit_rounded)
    );


    sign_decisor #(
        .N(N)
    ) sign_decisor_inst (
        .sign1(sign1),
        .sign2(sign2),
        .op(op),
        .sign(sign)
    );


    wire [N-1:0] pout_normal;
    set_sign #(
        .N(N)
    ) set_sign_inst (
        .posit_in(posit_rounded),
        .sign(sign),
        .posit_out(pout_normal)
    );

    assign pout = (p1_is_special || p2_is_special) ? pout_special : pout_normal;

endmodule



`ifdef TEST_BENCH_NOT_PPU

module tb_not_ppu;
    function [N-1:0] c2(input [N-1:0] a);
        c2 = ~a + 1'b1;
    endfunction
    function [N-1:0] abs(input [N-1:0] in);
        abs = in[N-1] == 0 ? in : c2(in);
    endfunction

    parameter N = `N;
    parameter ES = `ES;

    reg [N-1:0]  p1, p2;
    reg [OP_SIZE-1:0] op;
    reg [100:0] op_ascii;
    wire [N-1:0] pout;

    
    reg [N-1:0] pout_expected;
    reg diff_pout, pout_off_by_1;
    reg [9:0] pout_diff_analog;
    reg [N:0] test_no;

    reg [100:0] count_errors;

    not_ppu #(
        .N      (N),
        .ES     (ES)
    ) not_ppu_inst (
        .p1     (p1),
        .p2     (p2),
        .op     (op),
        .pout   (pout)
    );

    
    always @(*) begin
        diff_pout = pout === pout_expected ? 0 : 1'bx;
        pout_off_by_1 = abs(pout - pout_expected) == 0 ? 0 : abs(pout - pout_expected) == 1 ? 1 : 'bx;

        pout_diff_analog = abs(pout - pout_expected);
    end

    initial begin

             if (N == 8 && ES == 0) $dumpfile("tb_ppu_P8E0.vcd");
        else if (N == 5 && ES == 1) $dumpfile("tb_ppu_P5E1.vcd");
        else if (N == 16 && ES == 1)$dumpfile("tb_ppu_P16E1.vcd");
        else if (N == 32 && ES == 2)$dumpfile("tb_ppu_P32E2.vcd");
        else                        $dumpfile("tb_ppu.vcd");

        $dumpvars(0, tb_not_ppu);                        
            
        if (N == 8 && ES == 0) begin
            `include "../test_vectors/tv_posit_ppu_P8E0.sv"
        end

        if (N == 5 && ES == 1) begin
            `include "../test_vectors/tv_posit_ppu_P5E1.sv"
        end

        if (N == 16 && ES == 1) begin
            `include "../test_vectors/tv_posit_ppu_P16E1.sv"
        end

        if (N == 32 && ES == 2) begin
            `include "../test_vectors/tv_posit_ppu_P32E2.sv"
        end


        #10;
        $finish;
    end

endmodule
`endif
