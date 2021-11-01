// synopsys translate_off
`include "reg8.sv"
// synopsys translate_on

module p8_fx16(p8,fx16);
	input logic signed[7:0] p8;
	output logic[15:0] fx16;

	logic [6:0] reg_bits_w;
	wire [6:0]k_value_w;
	wire [2:0] reg_length_w;
	reg8 myreg8(.regbits (reg_bits_w),.k_val(k_value_w),.reg_length(reg_length_w));

	always @(*) begin: _
		logic pos_sign;
		logic signed[15:0] abs_fx;
		logic signed[7:0] abs_posit;
		logic signed[6:0] fx_int;
		logic [5:0] fx_mant;
		logic signed[6:0] posit_body,k_value;
		logic [2:0] reg_length;
		pos_sign = p8[7];
		abs_posit = (pos_sign)?(~p8+1):p8;
		posit_body = abs_posit[6:0];
		reg_bits_w = posit_body;
		k_value = k_value_w;
		reg_length = reg_length_w;
		fx_int = 1 << k_value[2:0];
		fx_mant = posit_body[5:0] << reg_length;
		if (k_value >= 0) begin
			abs_fx[15] = 0;
			abs_fx[14:9] = fx_int[6:1];
			abs_fx[8:3] = fx_mant;
			abs_fx[2:0] = 3'h0;
		end 
		else begin
			abs_fx[15:8] = 8'h0;
			abs_fx[7:0] = abs_posit << 2;
		end
		fx16 = (pos_sign)?~abs_fx+1:abs_fx;
	end
endmodule




/// p8_fx16 test bench
module p8_fx16_tb();

	logic signed[7:0] p8;
	wire [15:0] fx16;

	p8_fx16 p8_fx16_inst(.*);

	initial begin
		$dumpfile("p8_fx16_tb.vcd");
	    $dumpvars(0, p8_fx16_tb);

	    #10 	p8 = 8'b0000_0000;
	    #10 	p8 = 8'b1000_0001;
		#10 	p8 = 8'b0000_0010;
		#10 	p8 = 8'b0000_0011;
		#10 	p8 = 8'b0000_0100;
		#10 	p8 = 8'b0000_0000;
		$finish;
	end

endmodule
