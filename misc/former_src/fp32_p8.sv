module fp32_p8(fp32,p8);
	input logic[31:0] fp32;
	output logic[7:0] p8;
	logic [7:0] fp_norm_exp_w,pos_regime_w;
	ger8 myger8(.f_exp(fp_norm_exp_w),.regbits(pos_regime_w));
	always_comb begin
		logic fp_sign;
		logic signed [7:0] fp_exp,fp_norm_exp;
		logic [7:0] fp_hi_mant,pos_mant;
		logic [2:0] reg_length;
		logic [7:0] pos_regime;
		logic signed[7:0] pos_content;
		fp_sign = fp32[31];
		fp_exp = fp32[30:23];
		fp_hi_mant = fp32[22:18];
		fp_norm_exp = fp_exp - 8'h7f;
		fp_norm_exp_w = fp_norm_exp;
		pos_regime = pos_regime_w;
		if(fp_norm_exp[7] == 0) begin
			reg_length = fp_norm_exp[2:0];
		end
		else begin
			reg_length = (-(fp_norm_exp+1));
		end
		pos_mant = fp_hi_mant >> reg_length;
		
		pos_content = pos_regime | pos_mant;
		pos_content = (fp_exp == 8'hff)? pos_content | 8'h80 : pos_content;
		if(fp_sign == 0) begin
			p8 = pos_content;
		end
		else begin
			p8 = ~pos_content + 1;
		end
	end
endmodule
