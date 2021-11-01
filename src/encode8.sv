// synopsys translate_off
`include "ger8.sv"
// synopsys translate_on

module encode8(p8,r,k,f,s);
	output logic signed[7:0] p8;
	input logic[2:0] r;
	input logic s;
	input logic signed[7:0] k;
	input logic[7:0] f;
	logic [7:0] pos_mant;
	logic [2:0] reg_length;
	wire [7:0] pos_regime;
	logic signed[7:0] pos_content;
	ger8 myger8(.f_exp(k),.regbits(pos_regime));
	always @(*) begin



		if(k > 0) begin
			reg_length = k;
		end
		else begin
			reg_length=(-(k+1));
		end
		pos_mant = f >> (3+reg_length);
		
		pos_content = pos_regime | pos_mant;
		if(s == 0) begin
			p8 = pos_content;
		end
		else begin
			p8 = ~pos_content + 1;
		end
	end
endmodule
