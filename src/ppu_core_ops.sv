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
        input   [N-1:0]                                                 p1,
        input   [N-1:0]                                                 p2,
        input   [OP_SIZE-1:0]                                           op,
`ifdef FLOAT_TO_POSIT
        /************************************************************************/
        input  [(1+TE_SIZE+FRAC_FULL_SIZE)-1:0]                         float_fir,
        // input   [(1 + FLOAT_EXP_SIZE_F`F + FLOAT_MANT_SIZE_F`F)-1:0]    float_fir,
        output  [(fir_SIZE)-1:0]                                        posit_fir,
        /************************************************************************/
`endif
        output  [N-1:0]                                                 pout
    );


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
    wire [((N) + 1) -1:0] special;
    input_conditioning #(
        .N(N)
    ) input_conditioning (
        .p1_in(p1),
        .p2_in(p2),
        .op(op),
        .p1_out(p1_cond),
        .p2_out(p2_cond),
        .special(special)
    );

    assign is_special_or_trivial = special[0];
    assign pout_special_or_trivial = special >> 1;

    wire [fir_SIZE-1:0] fir1, fir2;

    posit_to_fir #(
        .N(N),
        .ES(ES)
    ) posit_to_fir1 (
        .p_cond(p1_cond),
        .fir(fir1)
    );

    wire [N-1:0] posit_in_posit_to_fir2;
    assign posit_in_posit_to_fir2 =
`ifdef FLOAT_TO_POSIT
        (op == POSIT_TO_FLOAT) ? p2 :
`endif
        p2_cond;

    posit_to_fir #(
        .N(N),
        .ES(ES)
    ) posit_to_fir2 (
        .p_cond(posit_in_posit_to_fir2),
        .fir(fir2)
    );

`ifdef FLOAT_TO_POSIT
    assign posit_fir = fir2;
`endif

    wire [TE_SIZE-1:0] ops_te_out;
    wire [FRAC_FULL_SIZE-1:0] ops_frac_full;

    wire sign_out_ops;
    wire [((1 + TE_SIZE + FRAC_FULL_SIZE) + 1)-1:0] ops_out;
    ops #(
        .N(N)
    ) ops_inst (
        .op(op),
        .fir1(fir1),
        .fir2(fir2),
        .ops_out(ops_out)
    );


    wire frac_lsb_cut_off;

    wire [N-1:0] pout_non_special;


    wire [((1 + TE_SIZE + FRAC_FULL_SIZE) + 1)-1:0] ops_wire;
    assign ops_wire =
`ifdef FLOAT_TO_POSIT
        (op == FLOAT_TO_POSIT) ? {float_fir, 1'b0} :
`endif
        ops_out;

    fir_to_posit #(
        .N(N),
        .ES(ES),
        .FIR_TOTAL_SIZE(1 + TE_SIZE + FRAC_FULL_SIZE)
    ) fir_to_posit_inst (
        .ops_in(ops_wire),
        .posit(pout_non_special)
    );

    assign pout = is_special_or_trivial ? pout_special_or_trivial : pout_non_special;

endmodule


