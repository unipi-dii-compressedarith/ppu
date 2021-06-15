module reg16(regbits,k_val,reg_length);
	input logic[14:0] regbits;
	output logic signed[6:0] k_val;
	output logic[3:0] reg_length;
	// Extract regime value and length from encoded regime
		
	logic [3:0] highest0_index,highest1_index;
	highest_set #(15,1) high_1(.bits (regbits),.index (highest1_index));
	highest_set #(15,0) high_0(.bits (regbits),.index (highest0_index));
	always_comb begin
		
		logic signed [6:0] leading_count;
		leading_count = 7'b0;

		if(regbits[6] == 0) begin
			leading_count = (highest1_index == 4'b1111)? 15:4'he - highest1_index;
			k_val = -leading_count;
			reg_length = leading_count;
		end	
		else begin
			leading_count = (highest0_index == 4'b1111)? 15:4'he - highest0_index;
			k_val = leading_count - 1;
			reg_length = leading_count;
		end
	end
endmodule
