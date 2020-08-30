module fx16_p8(fx16,p8);
	input logic[31:0] fx16;
	output logic[7:0] p8;
	logic [7:0] fx_int_log_w,pos_regime_w;
	ger8 myger8(.f_exp(fx_int_log_w),.regbits(pos_regime_w));
	logic [2:0] highest1_index;
	logic [6:0] fx_int_w;
	highest_set #(7,1) high_1(.bits (fx_int_w),.index (highest1_index));

	always_comb begin
		logic signed [15:0] abs_fx;
		logic [6:0] fx_int;
		logic [7:0] fx_mant;
		logic [7:0] fx_int_log_w;
		logic [7:0] pos_reg,pos_mant;
		logic signed [7:0] abs_pos;
		logic fx_sign;
		fx_sign = fx16[15];
		abs_fx = (fx_sign)?~fx16+1:fx16;
		fx_int = abs_fx[14:8];
		fx_mant = abs_fx[7:0];
		fx_int_w = fx_int;
		fx_int_log_w = 8'h6 - (3'h6 - highest1_index);
		pos_reg = pos_regime_w;
		pos_mant = fx_mant[7:3] >> (fx_int_log_w[2:0] << 1);
		if(fx_int == 6'h0) begin
			abs_pos = abs_fx >> 2;
		end
		else begin
			abs_pos = pos_reg & pos_mant;
		end
		p8 = (fx_sign)? ~abs_pos+1:abs_pos;
	end
endmodule
