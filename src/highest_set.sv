module highest_set #(parameter SIZE=8,parameter VAL=1,parameter OUTW=$clog2(SIZE))(bits,index);
	output logic[OUTW-1:0] index;
	input logic[SIZE-1:0] bits;
	
	wire [OUTW-1:0]out_stage[0:SIZE];
	assign out_stage[0] = ~0; // desired default output if no bits set
	generate genvar i;
    	for(i=0; i<SIZE; i=i+1)
        	assign out_stage[i+1] = (bits[i] == VAL) ? i : out_stage[i]; 
	endgenerate
	assign index = out_stage[SIZE];
endmodule
