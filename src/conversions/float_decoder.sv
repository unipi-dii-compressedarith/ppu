/*

iverilog -g2012 -DN=16 -DES=1 -DFSIZE=64 -DTB_FLOAT_DECODE float_decoder.sv && ./a.out

*/

// parameter EXP_SIZE_F64 = 11;
// parameter MANT_SIZE_F64 = 52;

// parameter EXP_SIZE_F32 = 8;
// parameter MANT_SIZE_F32 = 23;


module float_decoder #(
        parameter FSIZE = 64,
        parameter EXP_SIZE = 11,
        parameter MANT_SIZE = 52
    )(
        input [FSIZE-1:0] bits,
        output sign,
        output signed [EXP_SIZE-1:0] exp,
        output [MANT_SIZE-1:0] frac
    );

    parameter EXP_BIAS = (1 << (EXP_SIZE - 1)) - 1;

    assign sign = bits >> (FSIZE - 1) != 0;
    assign exp = ((bits & ((1 << (FSIZE - 1)) - 1)) >> MANT_SIZE) & ((1 << MANT_SIZE) - 1);
    assign frac = bits & ((1 << MANT_SIZE) - 1);

endmodule


`ifdef TB_FLOAT_DECODE
`define STRINGIFY(DEFINE) $sformatf("%0s", `"DEFINE`")

module tb_float_decoder;

    parameter FSIZE = 64;
    parameter EXP_SIZE = 11;
    parameter MANT_SIZE = 52;

    reg [FSIZE-1:0] bits;
    wire sign;
    wire [EXP_SIZE-1:0] exp;
    wire [MANT_SIZE-1:0] frac;

    
    float_decoder #(
        .FSIZE(FSIZE),
        .EXP_SIZE(EXP_SIZE),
        .MANT_SIZE(MANT_SIZE)
    ) float_decoder_inst (
        .bits(bits),
        .sign(sign),
        .exp(exp),
        .frac(frac)
    );


    initial begin
        $dumpfile({"tb_float_decoder_F",`STRINGIFY(`FSIZE),".vcd"});
        $dumpvars(0, tb_float_decoder);                        

        bits = 64'h405ee00000000000; #10;

    end


endmodule
`endif
