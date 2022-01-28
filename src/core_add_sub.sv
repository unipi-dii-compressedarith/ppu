module core_add_sub #(
        parameter N = 16
    )(
        input te1,
        input te2,
        input mant1,
        input mant2,
        input have_opposite_sign,
        
        output mant_out,
        output te_out
    );

    wire te_diff;
    assign te_diff = te1 - te2;


    wire mant1_upshifted, mant2_upshifted;
    assign mant1_upshifted = mant1 << size;
    assign mant2_upshifted = (mant2 << size) >> max(0, te_diff);


    assign mant_sum = mant1_upshifted
        + have_opposite_sign ? c2(mant2_upshifted, 2 * N) : mant2_upshifted;


    assign (mant, te_diff_updated) = match have_opposite_sign {
        true => core_sub(size as UInt, mant_sum, te_diff),
        false => core_add(size as UInt, mant_sum, te_diff),
    };

    

    core_sub (

    ) core_sub_inst (

    );

    core_add (

    ) core_add_inst (

    );

    assign te_out = te2 + te_diff_updated;

endmodule

