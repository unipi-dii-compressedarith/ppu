/*

iverilog -DTB_NEWTON_RAPHSON -g2012 -o newton_raphson.out ../src/newton_raphson.sv && ./newton_raphson.out

*/
module newton_raphson #(
        parameter SIZE = 10
    )(
        input [SIZE-1:0] num,
        input [SIZE-1:0] x0,
        output [SIZE-1:0] x1
    );


    // hardcoded for SIZE = 16 bits.
    // python -c 'from fixed2float import *; two = to_fixed(2.0, 3, 2*16 - 3); print(two.val)'
    wire [2*SIZE-1:0] two = 1073741824; 

    wire [3*SIZE-1:0] _x1;
    assign _x1 = x0 * (two - num * x0);

    wire round_bit;
    // one if any of the bits afterwards is 1.
    assign round_bit = |_x1[(3*SIZE-3-(SIZE))-1:0];

    assign x1 = _x1[(3*SIZE-3)-1-:(SIZE)] + round_bit;

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
