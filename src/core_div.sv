module core_div #(
        parameter N = 16
    )(
        input [TE_SIZE-1:0] te1,
        input [TE_SIZE-1:0] te2,
        input [MANT_SIZE-1:0] mant1,
        input [MANT_SIZE-1:0] mant2,
        output [(MANT_DIV_RESULT_SIZE)-1:0] mant_out,
        output [TE_SIZE-1:0] te_out
    );

    wire [TE_SIZE-1:0] te_diff;
    assign te_diff = te1 - te2;

    wire [(MANT_DIV_RESULT_SIZE)-1:0] mant_div;

    //// assign mant_div = (mant1 << (2 * size - 1)) / mant2;


    wire [(3*MANT_SIZE-4)-1:0] mant2_reciprocal;


// `define USE_LUT
`ifdef USE_LUT

    parameter LUT_WIDTH_IN = 13;
    parameter LUT_WIDTH_OUT = 13;

    //// python scripts/pacogen_mant_recip_LUT_gen.py -i 14 -o 39 > src/reciprocate_lut.sv
    generate
        if (MANT_SIZE < LUT_WIDTH_IN) begin
            // e.g P8
            reciprocate_lut #(
                .LUT_WIDTH_IN(LUT_WIDTH_IN),
                .LUT_WIDTH_OUT(LUT_WIDTH_OUT)
            ) reciprocate_lut_inst (
                .addr(mant2[MANT_SIZE-2 -: LUT_WIDTH_IN]),
                .out(_mant_out)
            );
            wire [(LUT_WIDTH_OUT)-1:0] _mant_out;
            assign mant2_reciprocal = {_mant_out, {3*MANT_SIZE-4 - LUT_WIDTH_IN{1'b0}}};
        end else begin
            // e.g. P16 upwards
            if (LUT_WIDTH_OUT > 3*MANT_SIZE-4) begin
                reciprocate_lut #(
                    .LUT_WIDTH_IN(LUT_WIDTH_IN),
                    .LUT_WIDTH_OUT(LUT_WIDTH_OUT)
                ) reciprocate_lut_inst (
                    .addr(mant2[MANT_SIZE-2 -: LUT_WIDTH_IN]),
                    .out(_mant_out)
                );
                wire [(LUT_WIDTH_OUT)-1:0] mant2_reciprocal;
                assign mant2_reciprocal = _mant_out[LUT_WIDTH_OUT -: (3*MANT_SIZE-4)];
            end else begin
                wire [(LUT_WIDTH_OUT)-1:0] _mant_out;
                reciprocate_lut #(
                    .LUT_WIDTH_IN(LUT_WIDTH_IN),
                    .LUT_WIDTH_OUT(LUT_WIDTH_OUT)
                ) reciprocate_lut_inst (
                    .addr(mant2[MANT_SIZE-2 -: LUT_WIDTH_IN]),
                    .out(_mant_out)
                );
                wire [(3*MANT_SIZE-4)-1:0] mant2_reciprocal;
                assign mant2_reciprocal = {_mant_out, {(3*MANT_SIZE-4) - LUT_WIDTH_OUT{1'b0}}} >> 1'b1;
            end
        end
    endgenerate


    wire [(3*MANT_SIZE-4)-1:0] mant2_reciprocal_fast_reciprocal;
    fast_reciprocal #(
        .SIZE(MANT_SIZE)
    ) fast_reciprocal_inst_dummy (
        .fraction(mant2),
        .one_over_fraction(mant2_reciprocal_fast_reciprocal)
    );

`else
    fast_reciprocal #(
        .SIZE(MANT_SIZE)
    ) fast_reciprocal_inst (
        .fraction(mant2),
        .one_over_fraction(mant2_reciprocal)
    );
`endif

    wire [(2*MANT_SIZE)-1:0] x1;
    newton_raphson #(
        .MS(MANT_SIZE)
    ) newton_raphson_inst (
        .num(mant2),
        .x0(mant2_reciprocal),
        .x1(x1)
    );

    assign mant_div = mant1 * x1;


    wire mant_div_less_than_one;
    assign mant_div_less_than_one =
        (mant_div & (1 << (3*MANT_SIZE-2))) == 0;

    assign mant_out =
        mant_div_less_than_one ? mant_div << 1 : mant_div;
    assign te_out =
        mant_div_less_than_one ? te_diff - 1 : te_diff;

endmodule
