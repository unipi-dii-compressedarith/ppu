module reg8(regbits,k_val,reg_length);
	input logic[6:0] regbits;
	output logic signed[6:0] k_val;
	output logic[2:0] reg_length;
	// Extract regime value and length from encoded regime
		
	logic [2:0] highest0_index,highest1_index;
	highest_set #(7,1) high_1(.bits (regbits),.index (highest1_index));
	highest_set #(7,0) high_0(.bits (regbits),.index (highest0_index));
	always_comb begin
		
		logic signed [6:0] leading_count;
		leading_count = 7'b0;

		if(regbits[6] == 0) begin
			leading_count = 3'h6 - highest1_index;
			k_val = -leading_count;
			reg_length = leading_count;
		end	
		else begin
			leading_count = 3'h6 - highest0_index;
			k_val = leading_count - 1;
			reg_length = leading_count;
		end
	end
endmodule
