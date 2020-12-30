module p160_p161(p160,p161);
	output logic signed[15:0] p161;
	input logic[15:0] p160;
    logic [14:0] reg_bits_w,reg_bits_wo;
	logic signed [6:0] k_value_w;
    logic signed[7:0] full_exp;
	logic [3:0] reg_length_w;
	reg16 myreg16(.regbits (reg_bits_w),.k_val(k_value_w),.reg_length(reg_length_w));
    ger16 myger16(.f_exp(full_exp),.regbits(reg_bits_wo));
    
	always_comb begin
		logic pos_sign;
		logic signed[15:0] abs_posit,fp_exp,fp_mant;
		logic signed[15:0] posit_body,pos_mant,pos_content;	
		logic signed[6:0] k_value;
		logic [3:0] reg_length;
		pos_sign = p160[15];
		abs_posit = (pos_sign)?(~p160+1):p161;
		posit_body = abs_posit[14:0];
		reg_bits_w = posit_body;
		k_value = k_value_w;
		reg_length = reg_length_w;
		posit_body = (posit_body << (k_value+1));
        full_exp = ({1'b0,k_value} << 1) + posit_body[15] + 8'h7f;
        pos_mant = posit_body << 2;
        pos_content = reg_bits_wo | pos_mant;
		if(pos_sign == 0) begin
			p161 = pos_content;
		end
		else begin
			p161 = ~pos_content + 1;
		end	end
endmodule
