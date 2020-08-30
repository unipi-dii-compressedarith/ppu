module p8_fp32(p8,fp32);
	input logic signed[7:0] p8;
	output logic[31:0] fp32;

	logic [6:0] reg_bits_w,k_value_w;
	logic [2:0] reg_length_w;
	reg8 myreg8(.regbits (reg_bits_w),.k_val(k_value_w),.reg_length(reg_length_w));
	
	always_comb begin
		logic pos_sign;
		logic signed[7:0] abs_posit,fp_exp,fp_mant;
		logic signed[6:0] posit_body,k_value;
		logic [2:0] reg_length;
		pos_sign = p8[7];
		abs_posit = (pos_sign)?(~p8+1):p8;
		posit_body = abs_posit[6:0];
		reg_bits_w = posit_body;
		k_value = k_value_w;
		reg_length = reg_length_w;
		fp_exp = k_value+8'h7f;
		fp_mant = posit_body << (reg_length + 4'b0010);
		fp32[31] = pos_sign;
		fp32[30:23] = fp_exp;
		fp32[22:15] = fp_mant;
		fp32[14:0] = 15'h0;
	end
endmodule
