/*
slide 4 @ https://www.synthworks.com/papers/VHDL_RTL_Pipelined_Multiplier_MAPLD_2002_S_BW.pdf

iverilog pp_mul.v mul.v && ./a.out
*/



module pp_mul #(
    parameter M = 48,
    parameter N = 64
) (
    input                  clk,
    input                  rst,
    input      [  (M)-1:0] a,
    input      [  (N)-1:0] b,
    output reg [(M+N)-1:0] product
);

    reg [(M+N)-1:0] product_st1;

    always_ff @(posedge clk) begin
        if (rst) begin
            // product_st1 <= 0;
            product <= 0;
        end else begin
            // product_st1 <= a * b;
            // product <= product_st1;
            product <= a * b;
        end
    end
endmodule





`ifdef TB_PP_MUL
module tb_pp_mul;

    parameter M = 48;
    parameter N = 64;

    reg              clk;
    reg              rst;
    reg  [  (M)-1:0] a;
    reg  [  (N)-1:0] b;
    wire [(M+N)-1:0] product;
    wire [(M+N)-1:0] p_mul;

    reg              diff;

    pp_mul #(
        .M(M),
        .N(N)
    ) pp_mul_inst (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .product(product)
    );

    mul #(
        .M(M),
        .N(N)
    ) mul_inst (
        .a(a),
        .b(b),
        .p(p_mul)
    );

    initial begin
        $dumpfile("tb_pp_mul.vcd");
        $dumpvars(0, tb_pp_mul);
    end

    always begin
        clk = ~clk;
        #10;
    end

    // initial $monitor("a=%d, x=%d, p_am=%d, p_mul=%d, diff=%d", a, x, p_am, p_mul, diff);

    parameter TCLK = 14;

    initial begin
        rst = 1;
        #24;
        rst = 0;
    end

    initial begin
        clk = 0;
        repeat (40) begin
            a = {$random} % 17'h10000;
            b = {$random} % 17'h10000;
            #TCLK;
        end
        $finish;  // $stop;
    end

    always @(posedge clk) begin
        diff = product === p_mul ? 0 : 'bx;
    end

endmodule

module mul #(
    parameter M = 4,
    parameter N = 8
) (
    input  [  (M)-1:0] a,
    input  [  (N)-1:0] b,
    output [(M+N)-1:0] p
);

    assign p = a * b;

endmodule

`endif
