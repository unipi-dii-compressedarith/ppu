// iverilog -g2012 sum8.sv decode8.sv encode8.sv reg8.sv ger8.sv highest_set.sv && ./a.out

module sum8(p8x,p8y,p8c); // Only positive numbers
	input logic signed[7:0] p8x,p8y;
	output signed[7:0] p8c;

    wire logic[7:0] fx,fy;
    wire signed[7:0] kx,ky;
    wire [2:0] rx,ry;
    wire sx,sy;
    logic sc;
    logic signed [7:0] kc;
    logic signed[7:0] kc_handle,alpha,alpha1;
	logic[7:0] fc,fx1,fy1; 
	logic[8:0] fc_handle;
    
	decode8 d8x(.p8(p8x),.s(sx),.f(fx),.k(kx),.r(rx));
	decode8 d8y(.p8(p8y),.s(sy),.f(fy),.k(ky),.r(ry));
	encode8 e8c(.p8(p8c),.s(sc),.f(fc),.k(kc_handle),.r({rc,rc,rc}));
                                                    /*  ^^^^ what was that supposed to be? */
	always @(*) begin
		kc = (kx > ky) ? kx:ky;
		fx1 = (fx >> (kc - kx)) +  (8'h80 >> (kc-kx-1));
		fy1 = (fy >> (kc - ky)) +  (8'h80 >> (kc-ky-1));
		alpha = (8'h01 >> kc-kx) + (8'h1 >> kc-ky) - 8'h01;
		fc_handle = (fx1 >> alpha) + (fy1 >> alpha);
		alpha1 = fc_handle[8];
		fc = fc_handle[7:0] >> alpha1;
		kc_handle = kc + alpha + alpha1;
		sc = 1'b0;
	end
endmodule






/// sum8 test bench
// synopsys translate_off
module sum8_tb();

    logic signed[7:0] p8x,p8y;
    wire signed [7:0] p8c;

    sum8 sum8_inst(.*);

    initial begin
        $dumpfile("sum8_tb.vcd");
        $dumpvars(0, sum8_tb);

                p8x = 8'b00000001;
                p8y = 8'b00000001;
        
        #10     p8x = 8'b00000001;
                p8y = 8'b00000010;
        
        #10     p8x = 8'b00000001;
                p8y = 8'b00000011;
        
        #10     p8x = 8'b00000001;
                p8y = 8'b00000100;
        
        #10     p8x = 8'b00000001;
                p8y = 8'b00000101;
        
        #10;
        $finish;
    end

endmodule
// synopsys translate_on
