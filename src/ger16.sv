module ger16(f_exp,regbits);
	output logic[15:0] regbits;
	input logic signed[15:0] f_exp;
	// Generate regime bitstring starting from float exponent

	always @(*) begin: _
		// take exp absolute value
		logic [15:0] abs_f_exp;
		logic [3:0] low_exp;
		logic signed[15:0] reg_placeholder,shifted_reg,built_reg;
		abs_f_exp = (f_exp[15])?-f_exp:+f_exp;
		reg_placeholder = (abs_f_exp >= 127)?16'h0000:16'h8000;
		
		// take the least 3 sign bits from abs exp
		low_exp = abs_f_exp[3:0];
		// shift right to build regime
		shifted_reg = reg_placeholder >>> low_exp;
		// build negative/positive regime
		if(f_exp[15] == 0) begin
			built_reg = shifted_reg >>> 1;
		end
		else begin
			built_reg = (shifted_reg >>> 1) & (~shifted_reg);
		end
		// reset sign
		regbits = built_reg & 16'h7fff;
	end
endmodule



`ifdef GER16_TB
module ger16_tb;


endmodule
`endif
