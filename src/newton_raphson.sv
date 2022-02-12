/*

iverilog -DTB_NEWTON_RAPHSON -g2012 -o newton_raphson.out ../src/newton_raphson.sv && ./newton_raphson.out

*/
module newton_raphson #(
        parameter SIZE = 10
    )(
        input [SIZE-1:0] num,
        input [(3*SIZE)-1:0] x0,
        output [(2*SIZE)-1:0] x1
    );

    wire [(3*SIZE+SIZE)-1:0] num_times_x0; // 4N
    assign num_times_x0 = (num * x0) << 1'd1;

    /*
    hardcoded for SIZE = 16 bits.
    $ python -c 'from fixed2float import to_Fx; N = 16; two = to_Fx(2.0, 2, 4*N); print(two.val)'
    */
    wire [(3*SIZE+SIZE)-1:0] two = 64'd9223372036854775808; // 4N

    
    wire [((3*SIZE+SIZE) + 3*SIZE)-1:0] _x1; // 7N
    assign _x1 = (x0 * (two - num_times_x0)) << 2'd3;

    assign x1 = _x1[(7*SIZE-1):(5*SIZE-1)+1];

endmodule


`ifdef TB_NEWTON_RAPHSON

module tb_newton_raphson;

    parameter SIZE = 16;
    reg [SIZE-1:0] num;
    reg [SIZE-1:0] x0;
    wire [SIZE-1:0] x1;

    newton_raphson #(
        .SIZE(SIZE)
    ) newton_raphson_inst (
        .num(num),
        .x0(x0),
        .x1(x1)
    );

    initial begin
        $dumpfile("tb_newton_raphson.vcd");
        $dumpvars(0, tb_newton_raphson);
    end

    
    initial begin

              num = 47104;
              x0 = 11364;

    #10;
    end


endmodule
`endif
