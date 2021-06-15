module ger8(f_exp,regbits);
	output logic[7:0] regbits;
	input logic signed[7:0] f_exp;
	// Generate regime bitstring starting from float exponent
    logic [7:0] abs_f_exp;
	always_comb begin
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
