module decode8(p8,r,k,f,s);
	input logic signed[7:0] p8;
	output logic[2:0] r;
	output logic s;
	output logic signed[7:0] k;
	output logic[7:0] f;



	logic [6:0] reg_bits_w;
	wire [6:0] k_value_w;
	wire [2:0] reg_length_w;
	reg8 myreg8(.regbits (reg_bits_w), .k_val(k_value_w), .reg_length(reg_length_w));
	
	always @(*) begin: _
		logic pos_sign;
		logic signed[7:0] abs_posit;
		logic signed[6:0] k_value;
		logic unsigned[7:0] posit_body;
		logic [2:0] reg_length;
		pos_sign = p8[7];
		abs_posit = (pos_sign)?(~p8+1):p8;
		posit_body = abs_posit[6:0];
		reg_bits_w = posit_body;
		k_value = k_value_w;
		reg_length = reg_length_w;
		f = posit_body << (reg_length + 4'b0010);
		r = reg_length;
		k = k_value;
		s = pos_sign;
	end
endmodule


// /// decode8 test bench
// synopsys translate_off
// module decode8_tb();
// 	reg signed [7:0] 	p8;
// 	wire [2:0] r;
// 	wire s;
// 	wire  signed [7:0] k;
// 	wire [7:0] f;

// 	decode8 decode8_inst(.*);
	
// 	initial begin
// 		$dumpfile("decode8_tb.vcd");
// 	    $dumpvars(0, decode8_tb);

// 	    #10 	p8 = 8'b0000001;
// 	    #10 	p8 = 8'b1111110;
// 		#10 	p8 = 8'b1011110;
// 		#10 	p8 = 8'b0000111;
// 		#10 	p8 = 8'b0000000;
// 		#10 	p8 = 8'b1111111;
// 		$finish;
// 	end

// endmodule
// synopsys translate_on