/*

iverilog -g2012 -DN=16 -DES=1 -DFSIZE=64 -DTB_FLOAT_DECODE float_encoder.sv && ./a.out

*/


module float_encoder #(
        parameter FSIZE = 64,
        parameter EXP_SIZE = 11,
        parameter MANT_SIZE = 52
    )(
        input sign,
        input signed [EXP_SIZE-1:0] exp,
        input [MANT_SIZE-1:0] frac,
        output [FSIZE-1:0] bits
    );

    parameter EXP_BIAS = (1 << (EXP_SIZE - 1)) - 1;

    assign bits = 0; // todo

endmodule


`ifdef TB_FLOAT_DECODE
`define STRINGIFY(DEFINE) $sformatf("%0s", `"DEFINE`")

module tb_float_encoder;

    parameter FSIZE = 64;
    parameter EXP_SIZE = 11;
    parameter MANT_SIZE = 52;

    reg sign;
    reg [EXP_SIZE-1:0] exp;
    reg [MANT_SIZE-1:0] frac;
    wire [FSIZE-1:0] bits;

    float_encoder #(
        .FSIZE(FSIZE),
        .EXP_SIZE(EXP_SIZE),
        .MANT_SIZE(MANT_SIZE)
    ) float_encoder_inst (
        .sign(sign),
        .exp(exp),
        .frac(frac),
        .bits(bits)
    );


    initial begin
        $dumpfile({"tb_float_encoder_F",`STRINGIFY(`FSIZE),".vcd"});
        $dumpvars(0, tb_float_encoder);                        

        bits = 64'h405ee00000000000; #10;

    end


endmodule
`endif
