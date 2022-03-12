/*


*/
module pack_fields #(
        parameter N = 4,
        parameter ES = 0
    )(
        input [FRAC_FULL_SIZE-1:0] frac_full,
        input [TE_SIZE-1:0] total_exp,
        input frac_lsb_cut_off, // new flag

        output [K_SIZE-1:0] k,
`ifndef NO_ES_FIELD
        output [ES-1:0] next_exp,
`endif
        output [MANT_SIZE-1:0] frac,

        // flags
        output round_bit,
        output sticky_bit,
        output k_is_oob,
        output non_zero_frac_field_size
    );

    wire [K_SIZE-1:0] k_unpacked;

`ifndef NO_ES_FIELD
    wire [ES-1:0] exp_unpacked;
`endif

    unpack_exponent #(
        .N(N),
        .ES(ES)
    ) unpack_exponent_inst (
        .total_exp(total_exp),
        .k(k_unpacked)
`ifndef NO_ES_FIELD
        ,.exp(exp_unpacked)
`endif
    );


    wire [K_SIZE-1:0] regime_k;
    assign regime_k = ($signed(k_unpacked) <= (N-2) && $signed(k_unpacked) >= -(N-2)) ? $signed(k_unpacked) : (
        $signed(k_unpacked) >= 0 ? N -2 : -(N-2)
    );

    assign k_is_oob = k_unpacked != regime_k;

    wire [REG_LEN_SIZE-1:0] reg_len;
    assign reg_len = $signed(regime_k) >= 0 ? regime_k + 2 : -$signed(regime_k) + 1;


    wire [MANT_LEN_SIZE-1:0] frac_len; // fix size
    assign frac_len = N - 1 - ES - reg_len;

`ifndef NO_ES_FIELD
    wire [(ES+1)-1:0] es_actual_len; // ES + 1 because it may potentially be negative.
    assign es_actual_len = min(ES, N - 1 - reg_len);


    wire [ES-1:0] exp1;
    assign exp1 = exp_unpacked >> max(0, ES - es_actual_len);
`endif


    wire [(S+2)-1:0] frac_len_diff;
    assign frac_len_diff = FRAC_FULL_SIZE - $signed(frac_len);


    compute_rouding #(
        .N(N),
        .ES(ES)
    ) compute_rouding_inst (
        .frac_len(frac_len),
        .frac_full(frac_full),
        .frac_len_diff(frac_len_diff),
        .k(regime_k),
`ifndef NO_ES_FIELD
        .exp(exp_unpacked),
`endif
        .frac_lsb_cut_off(frac_lsb_cut_off),

        .round_bit(round_bit),
        .sticky_bit(sticky_bit)
    );

    assign k = regime_k; // prev. k_unpacked which is wrong;

`ifndef NO_ES_FIELD
    wire [ES-1:0] exp2;
    assign exp2 = exp1 << (ES - es_actual_len);
`endif

    assign frac = frac_full >> frac_len_diff;

    assign non_zero_frac_field_size = $signed(frac_len) >= 0;

`ifndef NO_ES_FIELD
    assign next_exp = exp2;
`endif

endmodule
