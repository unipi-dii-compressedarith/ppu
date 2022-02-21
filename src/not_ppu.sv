/*


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
    wire [(3*MANT_SIZE)-1:0] mant_out_ops;
    wire [TE_SIZE-1:0] te1, te2, te_out_ops;

    wire sign1, sign2;

    

    posit_decode #(
        .N(N),
        .ES(ES)
    ) posit_decode_p1 (
        .bits(p1),
/////////////
        .sign(sign1),
        .te(te1),
        .mant(mant1),
/////////////
        .is_special()
    );

    posit_decode #(
        .N(N),
        .ES(ES)
    ) posit_decode_p2 (
        .bits(op == SUB ? c2(p2) : p2),
/////////////
        .sign(sign2),
        .te(te2),
        .mant(mant2),
/////////////
        .is_special()
    );
    
    
    ops #(
        .N(N)
    ) ops_inst (
        .op(op),
        .sign1(sign1),
        .sign2(sign2),
        .te1(te1),
        .te2(te2),
        .mant1(mant1),
        .mant2(mant2),
        .sign_out(sign_out_ops),
        .te_out(te_out_ops),
        .mant_out(mant_out_ops)
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
        .mant(mant_out_ops),
        .total_exp(te_out_ops),
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


    wire [N-1:0] pout_normal;
    wire sign_out_ops;
    set_sign #(
        .N(N)
    ) set_sign_inst (
        .posit_in(posit_rounded),
        .sign(sign_out_ops),
        .posit_out(pout_normal)
    );


    // TODO REMOVE
    wire p1_is_special = 0;
    wire p2_is_special = 0;
    wire pout_special;
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

        if (N == 8 && ES == 4) begin
            `include "../test_vectors/tv_posit_ppu_P8E4.sv"
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
