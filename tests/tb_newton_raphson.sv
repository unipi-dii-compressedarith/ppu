module tb_newton_raphson;
    parameter N = 16;
    reg [MS-1:0] num_i;
    reg [(3*MS)-1:0] x0_i;
    wire [(2*MS)-1:0] x1_o;

    newton_raphson #(
        .N(N)
    ) newton_raphson_inst (
        .clk_i(),
        .rst_i(),
        .num_i(num_i),
        .x0_i(x0_i),
        .x1_o(x1_o)
    );

    initial begin
        $dumpfile("tb_newton_raphson.vcd");
        $dumpvars(0, tb_newton_raphson);
    end

    initial begin
        num_i = 47104;
        x0_i = 11364;
        #10;
    end

endmodule
