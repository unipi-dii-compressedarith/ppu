module cls_vs_lzc #(
        parameter int unsigned WIDTH = 2,
        parameter bit          MODE  = 1'b0,
        parameter int unsigned CNT_WIDTH = cf_math_pkg::idx_width(WIDTH)
    ) (
        input  logic [WIDTH-1:0]     in_i,
        output logic [CNT_WIDTH-1:0] cnt_o,
        output logic                 empty_o
    );
        


    cls #(
        .N              (N)
    ) count_leading_zeros (
        .bits          (~posit),
        .leading_set    (leading_zeros),
        .index_highest_set(index_highest_set_2)
    );


    lzc #(
        .WIDTH(WIDTH),
        .MODE(MODE),
        .CNT_WIDTH(CNT_WIDTH)
    ) lzc_inst (
        .in_i(in_i),
        .cnt_o(cnt_o),
        .empty_o(empty_o)
    );



endmodule
