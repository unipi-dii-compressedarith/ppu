module reg8(
	input logic[6:0] regbits,
	output logic signed[6:0] k_val,
	output logic[2:0] reg_length
	);
	// Extract regime value and length from encoded regime
		
	wire [2:0] highest0_index,highest1_index;
	highest_set #(7,1) high_1(.bits (regbits),.index (highest1_index));
	highest_set #(7,0) high_0(.bits (regbits),.index (highest0_index));
	always @(*) begin: _ // `./reg8.sv:19: error: Variable declaration in unnamed block requires SystemVerilog.` thats why the name '_'
		
		logic signed [6:0] leading_count;
				
		leading_count = 7'b0;

		if (regbits[6] == 0) begin
			leading_count = (highest1_index == 3'b111)? 7:3'h6 - highest1_index;
			k_val = -leading_count;
			reg_length = leading_count;
		end	
		else begin
			leading_count = (highest0_index == 3'b111) ? 7:3'h6 - highest0_index;
			k_val = leading_count - 1;
			reg_length = leading_count;
		end
	end
endmodule




// /// reg8 test bench
// synopsys translate_off
// module reg8_tb();

// 	reg [6:0] regbits;
// 	wire [6:0] k_val;
// 	wire [2:0] reg_length;

// 	reg8 reg8_inst(.regbits(regbits),.k_val(k_val),.reg_length(reg_length));

// 	initial begin
// 		$dumpfile("reg8_tb.vcd");
// 	    $dumpvars(0, reg8_tb);

// 	    #10 	regbits = 7'b0000001;
// 	    #10 	regbits = 7'b1111110;
// 		#10 	regbits = 7'b1011110;
// 		#10 	regbits = 7'b0000111;
// 		#10 	regbits = 7'b0000000;
// 		#10 	regbits = 7'b1111111;
// 		$finish;
// 	end

// endmodule
// synopsys translate_on
