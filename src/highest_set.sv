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




// /// highest_set test bench
// synopsys translate_off
// module highest_set_tb();
// 	parameter SIZE = 8;
// 	parameter VAL = 1;
// 	parameter OUTW = $clog2(SIZE);

// 	reg [SIZE-1:0] bits;
// 	wire [OUTW-1:0] index;

// 	highest_set #(
// 		.SIZE(SIZE),
// 		.VAL(VAL),
// 		.OUTW(OUTW)
// 	)
// 	highest_set_inst(.*);

// 	initial begin
// 		$dumpfile("highest_set_tb.vcd");
// 	    $dumpvars(0, highest_set_tb);

// 	    #10 	bits = 10;
// 	    #10 	bits = 1;
// 		#10 	bits = 3;
// 		#10 	bits = 53;
// 		#10 	bits = 11;
// 		#10 	bits = 7;
// 		$finish;
// 	end
// endmodule
// synopsys translate_on
