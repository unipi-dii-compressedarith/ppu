/*

iverilog -g2012 -DN=16 -DES=1 -o shift_fields.out \
../src/shift_fields.sv \
../src/unpack_exponent.sv \
../src/utils.sv \
../src/compute_rounding.sv && ./shift_fields.out

*/
module shift_fields #(
        parameter N = `N,
        parameter ES = `ES
    )(
        input [2*MANT_SIZE-1:0] mant,
        input [TE_SIZE-1:0] total_exp,
        input [(2)-1:0] mant_non_factional_size,
        
        output [K_SIZE-1:0] k,
        output [ES-1:0] next_exp,
        output [MANT_SIZE-1:0] mant_downshifted,

        // flags
        output round_bit,
        output sticky_bit,
        output k_is_oob,
        output non_zero_mant_field_size
    );
    
    wire [K_SIZE-1:0] k_unpacked;
    wire [ES-1:0] exp_unpacked;
    unpack_exponent #(
        .N(N),
        .ES(ES)
    ) unpack_exponent_inst (
        .total_exp(total_exp),
        .k(k_unpacked),
        .exp(exp_unpacked)
    );


    wire [K_SIZE-1:0] regime_k;
    assign regime_k = ($signed(k_unpacked) <= (N-2) && $signed(k_unpacked) >= -(N-2)) ? $signed(k_unpacked) : (
        $signed(k_unpacked) >= 0 ? N -2 : -(N-2)
    );

    assign k_is_oob = k_unpacked != regime_k;

    wire [REG_LEN_SIZE-1:0] reg_len;
    assign reg_len = $signed(regime_k) >= 0 ? regime_k + 2 : -$signed(regime_k) + 1;

    
    wire [MANT_LEN_SIZE-1:0] mant_len;
    assign mant_len = N - 1 - ES - reg_len;

    wire [(ES+1)-1:0] es_actual_len; // ES + 1 because it can become -1.
    assign es_actual_len = min(ES, N - 1 - reg_len);


    wire [ES-1:0] exp_1;
    assign exp_1 = exp_unpacked >> max(0, ES - es_actual_len);


    wire [(S+2)-1:0] shift_mant_up;
    assign shift_mant_up = (N << 1); //2 * N;
    
    wire [(S+2)-1:0] mant_len_diff;
    assign mant_len_diff = $signed(shift_mant_up) - $signed(mant_len);

    wire [(2*MANT_SIZE+2)-1:0] mant_up_shifted; // +2 because `mant_non_factional_size` can be at most 2.
    assign mant_up_shifted = 
        (mant << mant_non_factional_size) & ((1 << shift_mant_up) - 1); //& mask(shift_mant_up);

    compute_rouding #(
        .N(N),
        .ES(ES)
    ) compute_rouding_inst (
        .mant_len(mant_len),
        .mant_up_shifted(mant_up_shifted),
        .mant_len_diff(mant_len_diff),
        .k(regime_k),
        .exp(exp_unpacked),
        .round_bit(round_bit),
        .sticky_bit(sticky_bit)
    );

    assign k = regime_k; // prev. k_unpacked which is wrong;

    wire [ES-1:0] exp_2;
    assign exp_2 = exp_1 << (ES - es_actual_len);

    assign mant_downshifted = mant_up_shifted >> mant_len_diff;

    assign non_zero_mant_field_size = $signed(mant_len) >= 0;

    assign next_exp = exp_2;

endmodule
