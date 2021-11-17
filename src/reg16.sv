// synopsys translate_off
`include "highest_set.sv"
// synopsys translate_on

module reg16(regbits,k_val,reg_length);
	input logic[14:0] regbits;
	output logic signed[6:0] k_val;
	output logic[3:0] reg_length;
	// Extract regime value and length from encoded regime
		
	// wire [3:0] highest0_index,highest1_index;
	// highest_set #(15,1) high_1(.bits (regbits),.index (highest1_index));
	// highest_set #(15,0) high_0(.bits (regbits),.index (highest0_index));
	// always @(*) begin: _
		
	// 	logic signed [6:0] leading_count;
	// 	leading_count = 7'b0;

	// 	if(regbits[6] == 0) begin
	// 		leading_count = (highest1_index == 4'b1111)? 15:4'he - highest1_index;
	// 		k_val = -leading_count;
	// 		reg_length = leading_count;
	// 	end	
	// 	else begin
	// 		leading_count = (highest0_index == 4'b1111)? 15:4'he - highest0_index;
	// 		k_val = leading_count - 1;
	// 		reg_length = leading_count;
	// 	end
	// end

	
	// assign first_reg_bit = p16[14];
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

            15'b10xxxxxxxxxxxxx: k_val =  0;
            15'b110xxxxxxxxxxxx: k_val =  1;
            15'b1110xxxxxxxxxxx: k_val =  2;
            15'b11110xxxxxxxxxx: k_val =  3;
            15'b111110xxxxxxxxx: k_val =  4;
            15'b1111110xxxxxxxx: k_val =  5;
            15'b11111110xxxxxxx: k_val =  6;
            15'b111111110xxxxxx: k_val =  7;
            15'b1111111110xxxxx: k_val =  8;
            15'b11111111110xxxx: k_val =  9;
            15'b111111111110xxx: k_val = 10;
            15'b1111111111110xx: k_val = 11;
            15'b11111111111110x: k_val = 12;
            15'b111111111111110: k_val = 13;
            15'b111111111111111: k_val = 14;
        endcase
        reg_length = 1 + (regbits[14] == 1'b1 ?  k_val + 1 : -k_val);
    end
endmodule



/// reg16 test bench
module reg16_tb();

	reg [14:0] regbits;
	wire [6:0] k_val;
	wire [3:0] reg_length;

	reg16 reg16_inst(.regbits(regbits),.k_val(k_val),.reg_length(reg_length));

	initial begin
		$dumpfile("reg16_tb.vcd");
	    $dumpvars(0, reg16_tb);

	    #2  	regbits = 15'b100000000000000;
	    #10 	regbits = 15'b110000000000000;
	    #10 	regbits = 15'b111000000000000;
	    #10 	regbits = 15'b111100000000000;
	    #10 	regbits = 15'b111110000000000;

	    #10;
		$finish;
	end

endmodule
