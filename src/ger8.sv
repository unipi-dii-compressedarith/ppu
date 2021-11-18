module ger8(f_exp,regbits);
	output logic[7:0] regbits;
	input logic signed[7:0] f_exp;
	// Generate regime bitstring starting from float exponent
    logic [7:0] abs_f_exp;
	always @(*) begin: _
		// take exp absolute value
		
		logic [2:0] low_exp;
		logic signed[7:0] reg_placeholder,shifted_reg,built_reg;
		abs_f_exp = (f_exp[7])?-f_exp:+f_exp;
		reg_placeholder = (abs_f_exp >= 127 )?8'h00:8'h80;
		//reg_placeholder = (abs_f_exp == 128 )?8'h00:8'h80;
		
		// take the least 3 sign bits from abs exp
		low_exp = abs_f_exp[2:0];
		// shift right to build regime
		shifted_reg = reg_placeholder >>> low_exp;
		// build negative/positive regime
		if(f_exp[7] == 0) begin
			built_reg = shifted_reg >>> 1;
		end
		else begin
			built_reg = (shifted_reg >>> 1) & (~shifted_reg);
		end
		// reset sign
		regbits = built_reg & 8'h7f;
	end
endmodule




// /// ger8 test bench
// synopsys translate_off
// module ger8_tb();
// 	logic signed[7:0] f_exp;
// 	wire [7:0] regbits;
	
// 	ger8 ger8_inst(.*);

// 	initial begin
// 		$dumpfile("ger8_tb.vcd");
// 	    $dumpvars(0, ger8_tb);

// 	    #10 	f_exp = 10;
// 	    #10 	f_exp = 1;
// 		#10 	f_exp = 3;
// 		#10 	f_exp = 53;
// 		#10 	f_exp = 11;
// 		#10 	f_exp = 7;
// 		$finish;
// 	end
// endmodule
// synopsys translate_on
