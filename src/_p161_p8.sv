module p161_p8(p161,p8);
	input logic[15:0] p161;
    output logic signed[7:0] p8;
	always @(*) begin
		p8 = p161 >> 8;
	end
endmodule
