module p160_fp32(p16,fp32);
	input logic signed[15:0] p16;
	output logic[31:0] fp32;

	logic [14:0] reg_bits_w;
	logic signed [6:0] k_value_w;
	logic [3:0] reg_length_w;
	reg16 myreg16(.regbits (reg_bits_w),.k_val(k_value_w),.reg_length(reg_length_w));
	
	always_comb begin
		logic pos_sign;
		logic signed[15:0] abs_posit,fp_exp,fp_mant;
		logic signed[15:0] posit_body;
		logic signed[6:0] k_value;
		logic [3:0] reg_length;
		pos_sign = p16[15];
		abs_posit = (pos_sign)?(~p16+1):p16;
		posit_body = abs_posit[14:0];
		reg_bits_w = posit_body;
		k_value = k_value_w;
		reg_length = reg_length_w;
		fp_exp = {k_value[6],k_value}+8'h7f;
		fp_mant = posit_body << (reg_length + 5'b0010);
		fp32[31] = pos_sign;
		fp32[30:23] = fp_exp;
		fp32[22:15] = fp_mant;
		fp32[14:0] = 15'h0;
	end
endmodule
