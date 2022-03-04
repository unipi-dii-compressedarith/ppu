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
        input   [(1 + FLOAT_EXP_SIZE_F`F + FLOAT_MANT_SIZE_F`F)-1:0]    float_pif,
        output  [(PIF_SIZE)-1:0]                                        posit_pif,
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
    input_conditioning #(
        .N(N)
    ) input_conditioning (
        .p1_in(p1),
        .p2_in(p2),
        .op(op),
        .p1_out(p1_cond),
        .p2_out(p2_cond),
        .is_special_or_trivial(is_special_or_trivial),
        .pout_special_or_trivial(pout_special_or_trivial)
    );


    wire [PIF_SIZE-1:0] pif1, pif2;

    posit_to_pif #(
        .N(N),
        .ES(ES)
    ) posit_to_pif1 (
        .p_cond(p1_cond),
        .pif(pif1)
    );

    wire [N-1:0] posit_in_posit_to_pif2;
    assign posit_in_posit_to_pif2 =
`ifdef FLOAT_TO_POSIT
        (op == POSIT_TO_FLOAT) ? p2 :
`endif
        p2_cond;

    posit_to_pif #(
        .N(N),
        .ES(ES)
    ) posit_to_pif2 (
        .p_cond(posit_in_posit_to_pif2),
        .pif(pif2)
    );

`ifdef FLOAT_TO_POSIT
    assign posit_pif = pif2;
`endif

    wire [TE_SIZE-1:0] ops_te_out;
    wire [FRAC_FULL_SIZE-1:0] ops_frac_full;

    wire sign_out_ops;
    wire [(1 + TE_SIZE + FRAC_FULL_SIZE)-1:0] pif_ops_out;
    ops #(
        .N(N)
    ) ops_inst (
        .op(op),
        .pif1(pif1),
        .pif2(pif2),
        .pif_ops_out(pif_ops_out),
        .frac_lsb_cut_off(frac_lsb_cut_off)
    );


    wire frac_lsb_cut_off;

    wire [N-1:0] pout_non_special;


`ifdef FLOAT_TO_POSIT
    wire [(1 + FLOAT_EXP_SIZE_F`F + FLOAT_MANT_SIZE_F`F)-1:0] pif_to_posit_in;
`else
    wire [(1 + TE_SIZE + FRAC_FULL_SIZE)-1:0] pif_to_posit_in;
`endif

    assign pif_to_posit_in =
`ifdef FLOAT_TO_POSIT
        (op == FLOAT_TO_POSIT) ? float_pif :
`endif
        pif_ops_out;

    wire frac_lsb_cut_off_pif_to_posit_in;
    assign frac_lsb_cut_off_pif_to_posit_in =
`ifdef FLOAT_TO_POSIT
        (op == FLOAT_TO_POSIT) ? 1'b0 :
`endif
        frac_lsb_cut_off;


    pif_to_posit #(
        .N(N),
        .ES(ES),
`ifdef FLOAT_TO_POSIT
        .PIF_TOTAL_SIZE(1 + FLOAT_EXP_SIZE_F`F + FLOAT_MANT_SIZE_F`F)
`else
        .PIF_TOTAL_SIZE(1 + TE_SIZE + FRAC_FULL_SIZE)
`endif
    ) pif_to_posit_inst (
        .pif(pif_to_posit_in),
        .frac_lsb_cut_off(frac_lsb_cut_off_pif_to_posit_in),
        .posit(pout_non_special)
    );

    assign pout = is_special_or_trivial ? pout_special_or_trivial : pout_non_special;

endmodule


