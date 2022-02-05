module fast_reciprocal #(
        parameter SIZE = 4
    )(
        input [SIZE-1:0] fraction,
        output [SIZE-1:0] one_over_fraction
    );

    wire [SIZE-1:0] i_data, o_data;
    assign i_data = fraction >> 1;

    reciprocal_approx #(
        .N(SIZE)
    ) reciprocal_approx_inst (
        .i_data(i_data),
        .o_data(o_data)
    );

    assign one_over_fraction = o_data >> 1;

endmodule
