module p8_p160(p8,p160);
	input logic signed[7:0] p8;
	output logic[15:0] p160;

	always_comb begin
		p160 = {p8,8'b0000000};
	end
endmodule         