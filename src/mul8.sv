// synopsys translate_off
`include "decode8.sv"
`include "encode8.sv"
// synopsys translate_on

module mul8(p8x,p8y,p8c); // Only positive numbers
	input logic signed[7:0] p8x,p8y;
	output logic signed[7:0] p8c;

    wire logic[7:0] fx,fy;
    wire signed[7:0] kx,ky;
    wire [2:0] rx,ry;
    wire sx,sy;
    logic sc;
    logic [2:0] Fx,Fy;
    logic [3:0] Fc;
    logic [7:0] fxe,fye;
    logic [15:0] fce;
	logic signed[7:0] kc, alpha,alpha1;
    wire signed[7:0] kc_handle;
	wire [7:0] fc_handle;
    
	decode8 d8x(.p8(p8x),.s(sx),.f(fx),.k(kx),.r(rx));
	decode8 d8y(.p8(p8y),.s(sy),.f(fy),.k(ky),.r(ry));
	encode8 e8c(.p8(p8c),.s(sc),.f(fc_handle),.k(kc_handle),.r(rc));
	always @(*) begin
		kc = kx + ky;
        sc = sx ^ sy;
        Fx = 6-rx; 
        Fy = 6-ry;
        Fc = (Fx > Fy) ? Fx:Fy;
        fxe = {1'b1,fx} >> (8-Fc);
        fye = {1'b1,fy} >> (8-Fc);
        fce = fxe*fye;
        alpha = fce[9:8] >> 1;
        fc_handle = fce[7:0] >> alpha;
        kc_handle = kc + alpha;
	end
endmodule




/// mul8 test bench
module mul8_tb();

    logic signed[7:0] p8x,p8y;
    wire signed [7:0] p8c;

    mul8 mul8_inst(.*);

    initial begin
        $dumpfile("mul8_tb.vcd");
        $dumpvars(0, mul8_tb);

        #10     p8x = 16'b0000_0000_0000_0000;
                p8y = 16'b0000_0000_0000_0000;
        #10     p8x = 16'b0000_0000_0000_0000;
                p8y = 16'b0000_0000_0000_0000;
        #10     p8x = 16'b0000_0000_0000_0000;
                p8y = 16'b0000_0000_0000_0000;
        #10     p8x = 16'b0000_0000_0000_0000;
                p8y = 16'b0000_0000_0000_0000;
        #10     p8x = 16'b0000_0000_0000_0000;
                p8y = 16'b0000_0000_0000_0000;
        #10     p8x = 16'b0000_0000_0000_0000;
                p8y = 16'b0000_0000_0000_0000;
        $finish;
    end

endmodule
