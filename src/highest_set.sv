/*

Description:
    Given a sequence of bits returns the highest index of said bits such that the bit is `VAL`.
    e.g.:
        bits = 8b00001001 -> 3

Usage:
    cd $PROJECT_ROOT/waveforms
    iverilog -DHIGHEST_SET_TB -o highest_set.out ../src/highest_set.sv && ./highest_set.out

    yosys -p "synth_intel -family max10 -top highest_set_v1 -vqm highest_set.vqm" ../src/highest_set.sv > yosys_intel_highest_set_v1.out
    yosys -p "synth_intel -family max10 -top highest_set_v2 -vqm highest_set.vqm" ../src/highest_set.sv > yosys_intel_highest_set_v2.out

*/


module highest_set_v1 #(
    parameter SIZE = 8,
    parameter VAL = 1,
    parameter OUTW = $clog2(SIZE)
)(
    input logic[SIZE-1:0] bits,
    output wire [OUTW-1:0] index
);
    
    wire [OUTW-1:0]out_stage[0:SIZE];
    assign out_stage[0] = ~0; // desired default output if no bits set

    generate genvar i;
        for (i=0; i<SIZE; i=i+1) begin: _gen
            assign out_stage[i+1] = (bits[i] == VAL) ? i : out_stage[i]; 
        end
    endgenerate

    assign index = out_stage[SIZE];

endmodule


/*
ref: http://www.ece.ualberta.ca/~jhan8/publications/1570528628.pdf
*/
module highest_set_v2 #(
        parameter SIZE = 8,
        parameter VAL = 1
    )(
        input logic [N-1:0] bits,
        output wire [N-1:0] index_bit,
        output wire [$clog2(N)-1:0] index
    );

    localparam N = SIZE;
    wire [N-1:0] _wire;
    
    generate
        for (genvar i=0; i<N-1; i=i+1) begin
            mux mux_inst (
                .a      (_wire[i+1]),
                .sel    (bits[i+1]),
                .and_in (bits[i]),
                .mux_out(_wire[i]),
                .and_out(index_bit[i])
            );
        end
    endgenerate

    assign _wire[N-1] = 1;
    assign index_bit[N-1] = bits[N-1];

    assign index = $clog2(index_bit); //// achtung, fails to synthesize.
endmodule


/// mux + and gate actually. only instantiated by `highest_set_v2`. maybe unnecessary later on.
module mux (
        input a,
        /* input b, */
        input sel,
        input and_in,
        output mux_out,
        output and_out
    );
    wire b = 0;
    assign mux_out = sel == 0 ? a : b;
    assign and_out = and_in & mux_out; 
endmodule

module highest_set_v3 #(
        parameter SIZE = 8,
        parameter VAL = 1
    )(
        input logic [N-1:0] bits,
        output wire [N-1:0] index_bit,
        output wire [$clog2(N)-1:0] index
    );

    function [N-1:0] c2(input [N-1:0] a);
        c2 = ~a + 1'b1;
    endfunction


    localparam N = SIZE;    

    wire [N-1:0] bits_reversed;
    wire [N-1:0] _index_bit_tmp;
    
    generate
        for (genvar i=0; i<N; i=i+1) begin
            assign bits_reversed[i] = bits[N-1-i];
        end
    endgenerate
    
    
    /// detect the rightmost bit-set index: 10'b0011001000 -> 5'b0000001000
    assign _index_bit_tmp = bits_reversed & c2(bits_reversed);


    generate
        for (genvar i=0; i<N; i=i+1) begin
            assign index_bit[i] = _index_bit_tmp[N-1-i];
        end
    endgenerate

endmodule


`ifdef HIGHEST_SET_TB
module tb_highest_set;
    parameter SIZE = 8;
    parameter VAL = 1;
    localparam OUTW = $clog2(SIZE);

    reg [SIZE-1:0] posit8;
    wire [OUTW-1:0] index_v1, index_v2, index_v3;

    reg diff;

    highest_set_v1 #(
        .SIZE   (SIZE),
        .VAL    (VAL)
    )
    highest_set_inst1 (
        .bits   (posit8),
        .index  (index_v1)
    );

    highest_set_v2 #(
        .SIZE   (SIZE),
        .VAL    (VAL)
    )
    highest_set_inst2 (
        .bits   (posit8),
        .index  (index_v2)
    );

    highest_set_v3 #(
        .SIZE   (SIZE),
        .VAL    (VAL)
    )
    highest_set_inst3 (
        .bits   (posit8),
        .index  (index_v3)
    );

    always @(*) begin
        diff = index_v1 == index_v2 ? 0 : 1'bx;
    end

    initial begin
        $dumpfile("tb_highest_set.vcd");
        $dumpvars(0, tb_highest_set);

                posit8 = 8'b0000_0001;
        #10     posit8 = 8'b0000_0011;
        #10     posit8 = 8'b0000_1000;
        #10     posit8 = 8'b0011_0000;
        #10     posit8 = 8'b0101_0101;
        #10     posit8 = 8'b1100_0000;
        #10     posit8 = 8'b1111_1111;

        #10;
        $finish;
    end
endmodule
`endif
