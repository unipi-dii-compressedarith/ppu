/*


*/

// `define N (16)
// `define ES (1)

// `ifdef ALTERA_RESERVED_QIS
// `define NO_ES_FIELD
// `endif

module ppu_core_ops #(
        parameter N = `N,
        parameter ES = `ES
`ifdef FLOAT_TO_POSIT
        ,parameter FSIZE = `F
`endif
    )(
        input                                           clk,
        input                                           rst,
        input           [N-1:0]                         p1,
        input           [N-1:0]                         p2,
        input       [OP_SIZE-1:0]                       op,
        output      [OP_SIZE-1:0]                       op_st2,
        input                                           stall,
`ifdef FLOAT_TO_POSIT
        input       [(1+TE_SIZE+FRAC_FULL_SIZE)-1:0]    float_fir,
        output      [(FIR_SIZE)-1:0]                    posit_fir,
`endif
        output      [N-1:0]                             pout
    );
    
    logic [OP_SIZE-1:0] op_st0, op_st1, op_st2;
    assign op_st0 = op; // alias


    wire [K_SIZE-1:0] k1, k2;
`ifndef NO_ES_FIELD
    wire [ES-1:0] exp1, exp2;
`endif

    wire [MANT_SIZE-1:0] mant1, mant2;
    wire [(3*MANT_SIZE)-1:0] mant_out_ops;
    wire [TE_SIZE-1:0] te1, te2, te_out_ops;

    wire sign1, sign2;


    wire [N-1:0] p1_cond, p2_cond;
    wire is_special_or_trivial;
    wire [N-1:0] pout_special_or_trivial;
    
    logic [(N+1)-1:0] special_st0, special_st1, special_st2, special_st3;
    input_conditioning #(
        .N(N)
    ) input_conditioning (
        .p1_in(p1),
        .p2_in(p2),
        .op(op_st0),
        .p1_out(p1_cond),
        .p2_out(p2_cond),
        .special(special_st0)
    );

    assign is_special_or_trivial = special_st3[0];
    assign pout_special_or_trivial = special_st3 >> 1;

    logic [FIR_SIZE-1:0] fir1_st0, fir1_st1;
    logic [FIR_SIZE-1:0] fir2_st0, fir2_st1;

    posit_to_fir #(
        .N(N),
        .ES(ES)
    ) posit_to_fir1 (
        .p_cond(p1_cond),
        .fir(fir1_st0)
    );

    wire [N-1:0] posit_in_posit_to_fir2;
    assign posit_in_posit_to_fir2 =
`ifdef FLOAT_TO_POSIT
        (op_st0 == POSIT_TO_FLOAT) ? p2 :
`endif
        p2_cond;

    posit_to_fir #(
        .N(N),
        .ES(ES)
    ) posit_to_fir2 (
        .p_cond(posit_in_posit_to_fir2),
        .fir(fir2_st0)
    );

`ifdef FLOAT_TO_POSIT
    assign posit_fir = fir2_st1;
`endif

    wire [TE_SIZE-1:0] ops_te_out;
    wire [FRAC_FULL_SIZE-1:0] ops_frac_full;

    reg_banks #() reg_banks_inst (
        .clk(clk),
        .rst(rst),
        .fir1_in(fir1_st0),
        .fir2_in(fir2_st0),
        .op_in(op_st0),
        .special_in(special_st0),
        .stall_i(stall),
        .delay_op(1'b0), // op_st0 !== DIV),
        .fir1_out(fir1_st1),
        .fir2_out(fir2_st1),
        .op_out(op_st1),
        .special_out(special_st1)
    );

    wire sign_out_ops;
    wire [((1 + TE_SIZE + FRAC_FULL_SIZE) + 1)-1:0] ops_out;
    ops #(
        .N(N)
    ) ops_inst (
        .clk(clk),
        .rst(rst),
        .op(op_st1),
        .fir1(fir1_st1),
        .fir2(fir2_st1),
        .ops_out(ops_out)
    );


    wire frac_truncated;

    wire [N-1:0] pout_non_special;


    reg [((1 + TE_SIZE + FRAC_FULL_SIZE) + 1)-1:0] ops_wire_st0, ops_wire_st1;

    assign ops_wire_st0 =
`ifdef FLOAT_TO_POSIT
        (op_st1 === FLOAT_TO_POSIT) ? {float_fir, 1'b0} :
`endif
        ops_out;

    
    fir_to_posit #(
        .N(N),
        .ES(ES),
        .FIR_TOTAL_SIZE(1 + TE_SIZE + FRAC_FULL_SIZE)
    ) fir_to_posit_inst (
        .ops_in(ops_wire_st1),
        .posit(pout_non_special)
    );

    assign pout = is_special_or_trivial ? pout_special_or_trivial : pout_non_special;

    always @(posedge clk) begin
        if (rst == 1'b1) begin
            ops_wire_st1 <= 'b0;
            special_st2 <= 'b0;
            special_st3 <= 'b0;
            op_st2 <= 'b0;
        end else begin
            ops_wire_st1 <= ops_wire_st0;
            special_st2 <= special_st1;
            special_st3 <= special_st2; // special_st3 <= (op_st1 === DIV) ? special_st2 : special_st1;
            op_st2 <= op_st1;
        end
    end

endmodule


