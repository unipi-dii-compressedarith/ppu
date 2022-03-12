/*

iverilog -DTB_NEWTON_RAPHSON -g2012 -o newton_raphson.out ../src/newton_raphson.sv && ./newton_raphson.out

*/
module newton_raphson #(
        parameter MS = 10
    )(
        input   [(MS)-1:0]      num,
        input   [(3*MS-4)-1:0]  x0,
        output  [(2*MS)-1:0]    x1
    );

    /*

    num                     :   Fx<1, MS>
    x0                      :   Fx<1, 3MS - 4>

    num * x0                :   Fx<2, 4MS - 4>      -> Fx<2, 2MS> (downshifted by ((4MS-4) - (2MS) = 2MS - 4)

    2                       :   Fx<2, 2MS>

    2 - num * x0            :   Fx<2, 2MS>

    x0_2n                   :   Fx<1, 2MS>          -> x0 downshifted by ((3MS - 3) - (2MS) = MS - 3)

    x0_2n * (2 - num * x0)  :   Fx<3, 4MS>          -> downshifted by ((4MS) - (2MS) - 2 = 2MS).
                                                                                       └── due to being:   000.101000111011101001110 vs      (what you have)
                                                                                                             0.10100011110                   (what you want)

    */

    wire [(4*MS-3)-1:0] _num_times_x0;
    assign _num_times_x0 = (num * x0) >> (2*MS - 4);
    wire [(2*MS)-1:0] num_times_x0;
    assign num_times_x0 = _num_times_x0;



    /// generated with `scripts/gen_fixed_point_values.py`
    wire [(2*MS)-1:0] fx_2 = fx_2___N`N;

    wire [(2*MS)-1:0] two_minus_num_x0;
    assign two_minus_num_x0 = fx_2 - num_times_x0;


    wire [(2*MS)-1:0] x0_on_2n_bits;
    assign x0_on_2n_bits = x0 >> (MS - 4);

    wire [(4*MS)-1:0] _x1;
    assign _x1 = x0_on_2n_bits * two_minus_num_x0;

    wire [(2*MS)-1:0] x1;
    // assign x1 = _x1[(4*MS-1)-:MS];
    assign x1 = _x1 >> (2*MS - 2);

endmodule


`ifdef TB_NEWTON_RAPHSON

module tb_newton_raphson;

    parameter MS = 16;
    reg [MS-1:0] num;
    reg [(3*MS)-1:0] x0;
    wire [(2*MS)-1:0] x1;

    newton_raphson #(
        .MS(MS)
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
