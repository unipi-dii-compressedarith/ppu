module p8_p161(p8,p161);
	input logic signed[7:0] p8;
	output logic[15:0] p161;

	always_comb begin
		p161 = {p8,'b0000000};
	end
endmodule         