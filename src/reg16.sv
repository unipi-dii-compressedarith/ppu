// synopsys translate_off
`include "highest_set.sv"
// synopsys translate_on

module reg16(regbits,k_val,reg_length);
	input logic[14:0] regbits;
	output logic signed[6:0] k_val;
	output logic[3:0] reg_length;
	// Extract regime value and length from encoded regime
		
	wire [3:0] highest0_index,highest1_index;
	highest_set #(15,1) high_1(.bits (regbits),.index (highest1_index));
	highest_set #(15,0) high_0(.bits (regbits),.index (highest0_index));
	always @(*) begin: _
		
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



/// reg16 test bench
module reg16_tb();

	reg [14:0] regbits;
	wire [6:0] k_val;
	wire [3:0] reg_length;

	reg16 reg16_inst(.regbits(regbits),.k_val(k_val),.reg_length(reg_length));

	initial begin
		$dumpfile("reg16_tb.vcd");
	    $dumpvars(0, reg16_tb);

	    #10 	regbits = 7'b0000001;
	    #10 	regbits = 7'b1111110;
		#10 	regbits = 7'b1011110;
		#10 	regbits = 7'b0000111;
		#10 	regbits = 7'b0000000;
		#10 	regbits = 7'b1111111;
		$finish;
	end

endmodule
