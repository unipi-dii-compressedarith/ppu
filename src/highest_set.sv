/*
iverilog -DHIGHEST_SET_TB highest_set.sv && ./a.out
*/

module highest_set #(
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




`ifdef HIGHEST_SET_TB
module highest_set_tb();
    parameter SIZE = 8;
    parameter VAL = 1;
    localparam OUTW = $clog2(SIZE);

    reg [SIZE-1:0] posit8;
    wire [OUTW-1:0] index;

    highest_set #(
        .SIZE   (SIZE),
        .VAL    (VAL)
    )
    highest_set_inst(
        .bits   (posit8),
        .index  (index)
    );


    initial begin
        $dumpfile("highest_set_tb.vcd");
        $dumpvars(0, highest_set_tb);

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
