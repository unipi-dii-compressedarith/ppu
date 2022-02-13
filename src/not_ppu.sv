/*


*/

`define STRINGIFY(DEFINE) $sformatf("%0s", `"DEFINE`")

// `define N (16)
// `define ES (1)

// `ifdef ALTERA_RESERVED_QIS
// `define NO_ES_FIELD
// `endif

module not_ppu #(
        parameter N = `N,
        parameter ES = `ES
    )(
        input   [N-1:0]         p1,
        input   [N-1:0]         p2,
        input   [OP_SIZE-1:0]   op,
        output  [N-1:0]         pout
    );
    
    
    wire [K_SIZE-1:0] k1, k2;
`ifndef NO_ES_FIELD
    wire [ES-1:0] exp1, exp2;
`endif

    wire [MANT_SIZE-1:0] mant1, mant2;
    wire [(3*MANT_SIZE)-1:0] mant_out_core_op;
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
`ifndef NO_ES_FIELD
        .exp(exp1),
`endif
        .mant(mant1)
    );

    unpack_posit #(
        .N(N),
        .ES(ES)
    ) unpack_posit_2 (
        .bits(p2_out_cond),
        .sign(sign2),
        .k(k2),
`ifndef NO_ES_FIELD
        .exp(exp2),
`endif
        .mant(mant2)
    );

    total_exponent #(
        .N(N),
        .ES(ES)
    ) total_exponent_1 (
        .k(k1),
`ifndef NO_ES_FIELD
        .exp(exp1),
`endif
        .total_exp(te1)
    );

    total_exponent #(
        .N(N),
        .ES(ES)
    ) total_exponent_2 (
        .k(k2),
`ifndef NO_ES_FIELD
        .exp(exp2),
`endif
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



    wire [K_SIZE-1:0] k;
`ifndef NO_ES_FIELD
    wire [ES-1:0] next_exp;
`endif
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
        .op(op),

        .k(k),
`ifndef NO_ES_FIELD
        .next_exp(next_exp),
`endif
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
`ifndef NO_ES_FIELD
        .exp(next_exp),
`endif
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
    parameter N = `N;
    parameter ES = `ES;

    reg [N-1:0]  p1, p2;
    reg [OP_SIZE-1:0] op;
    reg [100:0] op_ascii;
    wire [N-1:0] pout;

    reg [300:0] p1_ascii, p2_ascii, pout_ascii, pout_gt_ascii;

    
    reg [N-1:0] pout_ground_truth, pout_hwdiv_expected;
    reg diff_pout_ground_truth, diff_pout_hwdiv_exp, pout_off_by_1;
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
        diff_pout_ground_truth = pout === pout_ground_truth ? 0 : 1'bx;
        pout_off_by_1 = abs(pout - pout_ground_truth) == 0 ? 0 : abs(pout - pout_ground_truth) == 1 ? 1 : 'bx;
        diff_pout_hwdiv_exp = (op != DIV) ? 'hz : pout === pout_hwdiv_expected ? 0 : 1'bx;
    end




    reg [10-1:0] nn, ee;
    initial begin

        $dumpfile({"tb_ppu_P",`STRINGIFY(`N),"E",`STRINGIFY(`ES),".vcd"});
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
