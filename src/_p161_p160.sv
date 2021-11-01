// synopsys translate_off
`include "reg16.sv"
`include "ger16.sv"
// synopsys translate_on

module p161_p160(p161,p160);
	input logic[15:0] p161;
	output logic signed[15:0] p160;


    logic [14:0] reg_bits_w;
	wire [15:0] reg_bits_wo;
	wire signed [6:0] k_value_w;
    logic signed[15:0] full_exp;
	wire [3:0] reg_length_w;
	reg16 myreg16(.regbits (reg_bits_w),.k_val(k_value_w),.reg_length(reg_length_w));
    ger16 myger16(.f_exp(full_exp),.regbits(reg_bits_wo));
    
	always @(*) begin: _
		logic pos_sign;
		logic signed[15:0] abs_posit,fp_exp,fp_mant;
		logic signed[15:0] posit_body,pos_mant,pos_content;	
		logic signed[6:0] k_value;
		logic [3:0] reg_length;
		pos_sign = p161[15];
		abs_posit = (pos_sign)?(~p161+1):p161;
		posit_body = abs_posit[14:0];
		reg_bits_w = posit_body;
		k_value = k_value_w;
		reg_length = reg_length_w;
		posit_body = (posit_body << (k_value+1));
        full_exp = ({1'b0,k_value} << 1) + posit_body[15] + 8'h7f;
        pos_mant = posit_body << 2;
        pos_content = reg_bits_wo | pos_mant;
		if(pos_sign == 0) begin
			p160 = pos_content;
		end
		else begin
			p160 = ~pos_content + 1;
		end	end
endmodule



/// p161_p160 test bench
module p161_p160_tb();
	
	logic[15:0] p161;
	wire signed[15:0] p160;
	
	p161_p160 p161_p160_inst(.p161(p161), .p160(p160));

	initial begin
		$dumpfile("p161_p160_tb.vcd");
	    $dumpvars(0, p161_p160_tb);

	    #1 		p161 = 16'b0_00001_1_000000000;
	    #10 	p161 = 16'b0_00001_0_000000001;
		#10 	p161 = 16'b0_00001_0_000000011;
		#10 	p161 = 16'b0_00001_0_000000000;
		#10 	p161 = 16'b1_00001_0_000000000;
		#10 	p161 = 16'b0_11110_0_000000000;
		$finish;
	end

endmodule
