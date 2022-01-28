module shift_fields #(
        parameter N = 16,
        parameter ES = 1
    )(
        input mant,
        input total_exp,
        input mant_non_factional_size,
        
        output k,
        output next_exp,
        output mant_downshifted,

        output round_bit,
        output sticky_bit,
        output k_is_oob,
        output non_zero_mant_field_size
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

    unpack_exponent #(
        .N(N),
        .ES(ES)
    ) unpack_exponent_inst (
        .total_exp(total_exp),
        .k(k),
        .exp(exp)
    );


    wire regime_k;
    assign regime_k = (k <= (N-2) && k >= -(N-2)) ? k : (
        k >= 0 ? N -2 : -(N-2)
    );

    assign k_is_oob = k != regime_k;

    wire reg_len;
    assign reg_len = regime_k >= 0 ? regime_k + 2 : -regime_k + 1;

    assign mant_len = N - 1 - ES - reg_len;

    assign es_actual_len = min(ES, N - 1 - reg_len);


    wire exp_1, exp_2;

    assign exp_1 = exp >> max(0, ES - es_actual_len);

    assign shift_mant_up = 2 * N;
    assign mant_len_diff = shift_mant_up - mant_len;

    assign mant_up_shifted = (mant << mant_non_factional_size); //& mask(shift_mant_up);

    compute_rouding #(
        .N(N),
        .ES(ES)
    ) compute_rouding_inst (
        .mant_len(mant_len),
        .mant_up_shifted(mant_up_shifted),
        .mant_len_diff(mant_len_diff),
        .k(k),
        .exp(exp),
        .round_bit(round_bit),
        .sticky_bit(sticky_bit)
    );


    assign exp_2 = exp_1 << (ES - es_actual_len);

    assign mant_down_shifted = mant_up_shifted >> mant_len_diff;

    assign non_zero_mant_field_size = mant_len >= 0;

endmodule
