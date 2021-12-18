module p161_p160 (
	p161,
	p160
);
	input wire [15:0] p161;
	output reg signed [15:0] p160;
	reg [14:0] reg_bits_w;
	wire [15:0] reg_bits_wo;
	wire signed [6:0] k_value_w;
	reg signed [15:0] full_exp;
	wire [3:0] reg_length_w;
	reg16 myreg16(
		.regbits(reg_bits_w),
		.k_val(k_value_w),
		.reg_length(reg_length_w)
	);
	ger16 myger16(
		.f_exp(full_exp),
		.regbits(reg_bits_wo)
	);
	always @(*) begin : sv2v_autoblock_1
		reg pos_sign;
		reg signed [15:0] abs_posit;
		reg signed [15:0] fp_exp;
		reg signed [15:0] fp_mant;
		reg signed [15:0] posit_body;
		reg signed [15:0] pos_mant;
		reg signed [15:0] pos_content;
		reg signed [6:0] k_value;
		reg [3:0] reg_length;
		pos_sign = p161[15];
		abs_posit = (pos_sign ? ~p161 + 1 : p161);
		posit_body = abs_posit[14:0];
		reg_bits_w = posit_body;
		k_value = k_value_w;
		reg_length = reg_length_w;
		posit_body = posit_body << (k_value + 1);
		full_exp = (({1'b0, k_value} << 1) + posit_body[15]) + 8'h7f;
		pos_mant = posit_body << 2;
		pos_content = reg_bits_wo | pos_mant;
		if (pos_sign == 0)
			p160 = pos_content;
		else
			p160 = ~pos_content + 1;
	end
endmodule
module p161_p160_tb;
	reg [15:0] p161;
	wire signed [15:0] p160;
	p161_p160 p161_p160_inst(
		.p161(p161),
		.p160(p160)
	);
	initial begin
		$dumpfile("p161_p160_tb.vcd");
		$dumpvars(0, p161_p160_tb);
		#(1) p161 = 16'b0000011000000000;
		#(10) p161 = 16'b0000010000000001;
		#(10) p161 = 16'b0000010000000011;
		#(10) p161 = 16'b0000010000000000;
		#(10) p161 = 16'b1000010000000000;
		#(10) p161 = 16'b0111100000000000;
		#(10)
			;
	end
endmodule
module reg16 (
	regbits,
	k_val,
	reg_length
);
	input wire [14:0] regbits;
	output reg signed [6:0] k_val;
	output reg [3:0] reg_length;
	always @(*) begin
		casex (regbits)
			15'b000000000000000: k_val = -15;
			15'b000000000000001: k_val = -14;
			15'b00000000000001x: k_val = -13;
			15'b0000000000001xx: k_val = -12;
			15'b000000000001xxx: k_val = -11;
			15'b00000000001xxxx: k_val = -10;
			15'b0000000001xxxxx: k_val = -9;
			15'b000000001xxxxxx: k_val = -8;
			15'b00000001xxxxxxx: k_val = -7;
			15'b0000001xxxxxxxx: k_val = -6;
			15'b000001xxxxxxxxx: k_val = -5;
			15'b00001xxxxxxxxxx: k_val = -4;
			15'b0001xxxxxxxxxxx: k_val = -3;
			15'b001xxxxxxxxxxxx: k_val = -2;
			15'b01xxxxxxxxxxxxx: k_val = -1;
			15'b10xxxxxxxxxxxxx: k_val = 0;
			15'b110xxxxxxxxxxxx: k_val = 1;
			15'b1110xxxxxxxxxxx: k_val = 2;
			15'b11110xxxxxxxxxx: k_val = 3;
			15'b111110xxxxxxxxx: k_val = 4;
			15'b1111110xxxxxxxx: k_val = 5;
			15'b11111110xxxxxxx: k_val = 6;
			15'b111111110xxxxxx: k_val = 7;
			15'b1111111110xxxxx: k_val = 8;
			15'b11111111110xxxx: k_val = 9;
			15'b111111111110xxx: k_val = 10;
			15'b1111111111110xx: k_val = 11;
			15'b11111111111110x: k_val = 12;
			15'b111111111111110: k_val = 13;
			15'b111111111111111: k_val = 14;
		endcase
		reg_length = 1 + (regbits[14] == 1'b1 ? k_val + 1 : -k_val);
	end
endmodule
module ger16 (
	f_exp,
	regbits
);
	output reg [15:0] regbits;
	input wire signed [15:0] f_exp;
	always @(*) begin : _
		reg [15:0] abs_f_exp;
		reg [3:0] low_exp;
		reg signed [15:0] reg_placeholder;
		reg signed [15:0] shifted_reg;
		reg signed [15:0] built_reg;
		abs_f_exp = (f_exp[15] ? -f_exp : +f_exp);
		reg_placeholder = (abs_f_exp >= 127 ? 16'h0000 : 16'h8000);
		low_exp = abs_f_exp[3:0];
		shifted_reg = reg_placeholder >>> low_exp;
		if (f_exp[15] == 0)
			built_reg = shifted_reg >>> 1;
		else
			built_reg = (shifted_reg >>> 1) & ~shifted_reg;
		regbits = built_reg & 16'h7fff;
	end
endmodule
