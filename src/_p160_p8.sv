module p160_p8(p160,p8);
	output logic signed[7:0] p8;
	input logic[15:0] p160;
	always_comb begin
		p8 = p160 >> 8;
	end
endmodule
