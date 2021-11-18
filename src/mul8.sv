/*
~/Documents/dev/yosys/yosys -p "synth_intel -family max10 -top mul8 -vqm mul8.vqm" mul8.sv decode8.sv encode8.sv reg8.sv ger8.sv highest_set.sv > yosys.out
*/

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
    logic signed[7:0] kc_handle;
	logic [7:0] fc_handle;
    
	decode8 d8x(.p8(p8x),.s(sx),.f(fx),.k(kx),.r(rx));
	decode8 d8y(.p8(p8y),.s(sy),.f(fy),.k(ky),.r(ry));
	encode8 e8c(.p8(p8c),.s(sc),.f(fc_handle),.k(kc_handle),.r(/* rc ?*/));
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
// synopsys translate_off
module mul8_tb();

    logic signed[7:0] p8x,p8y;
    wire signed [7:0] p8c;

    reg [7:0] p8c_exp;
    reg z_diff;

    always @(*) z_diff = p8c_exp === p8c ? 0 : 1'bx;

    mul8 mul8_inst(.*);

    initial begin
        $dumpfile("mul8_tb.vcd");
        $dumpvars(0, mul8_tb);
    end

    initial begin
                // zer   something = zero
                p8x = 8'h00;            
                p8y = 8'h61;        
                p8c_exp = 8'h00;

        #10;    
            // NaR * something = NaR
                p8x = 8'h80;            
                p8y = 8'h23;        
                p8c_exp = 8'h80;

        #10;
            /* test #3 */
            p8x         = 8'hda; /* -0.59375 */
            p8y         = 8'h3e; /* 0.96875 */
            p8c_exp       = 8'hdb; /* -0.578125 */
        
        #10;
            /* test #4 */
            p8x         = 8'hba; /* -1.1875 */
            p8y         = 8'h0d; /* 0.203125 */
            p8c_exp       = 8'hf1; /* -0.234375 */
        
        #10;
            /* test #5 */
            p8x         = 8'hd7; /* -0.640625 */
            p8y         = 8'h70; /* 4.0 */
            p8c_exp       = 8'h9c; /* -2.5 */
        
        #10;
            /* test #6 */
            p8x         = 8'h0f; /* 0.234375 */
            p8y         = 8'h32; /* 0.78125 */
            p8c_exp       = 8'h0c; /* 0.1875 */
        
        #10;
            /* test #7 */
            p8x         = 8'hc4; /* -0.9375 */
            p8y         = 8'h9f; /* -2.125 */
            p8c_exp       = 8'h60; /* 2.0 */
        
        #10;
            /* test #8 */
            p8x         = 8'hbc; /* -1.125 */
            p8y         = 8'hf8; /* -0.125 */
            p8c_exp       = 8'h09; /* 0.140625 */
        
        #10;
            /* test #9 */
            p8x         = 8'h0d; /* 0.203125 */
            p8y         = 8'h06; /* 0.09375 */
            p8c_exp       = 8'h01; /* 0.015625 */
        
        #10;
            /* test #10 */
            p8x         = 8'h65; /* 2.625 */
            p8y         = 8'h8e; /* -5.0 */
            p8c_exp       = 8'h85; /* -14.0 */
        
        #10;
            /* test #11 */
            p8x         = 8'h22; /* 0.53125 */
            p8y         = 8'h6e; /* 3.75 */
            p8c_exp       = 8'h60; /* 2.0 */
        
        #10;
            /* test #12 */
            p8x         = 8'hff; /* -0.015625 */
            p8y         = 8'h9a; /* -2.75 */
            p8c_exp       = 8'h03; /* 0.046875 */
        
        #10;
            /* test #13 */
            p8x         = 8'hde; /* -0.53125 */
            p8y         = 8'h62; /* 2.25 */
            p8c_exp       = 8'hba; /* -1.1875 */
        
        #10;
            /* test #14 */
            p8x         = 8'h3c; /* 0.9375 */
            p8y         = 8'he2; /* -0.46875 */
            p8c_exp       = 8'he4; /* -0.4375 */
        
        #10;
            /* test #15 */
            p8x         = 8'h50; /* 1.5 */
            p8y         = 8'h6e; /* 3.75 */
            p8c_exp       = 8'h73; /* 5.5 */
        
        #10;
            /* test #16 */
            p8x         = 8'h06; /* 0.09375 */
            p8y         = 8'h67; /* 2.875 */
            p8c_exp       = 8'h11; /* 0.265625 */
        
        #10;
            /* test #17 */
            p8x         = 8'h64; /* 2.5 */
            p8y         = 8'h45; /* 1.15625 */
            p8c_exp       = 8'h67; /* 2.875 */
        
        #10;
            /* test #18 */
            p8x         = 8'he0; /* -0.5 */
            p8y         = 8'h9b; /* -2.625 */
            p8c_exp       = 8'h4a; /* 1.3125 */
        
        #10;
            /* test #19 */
            p8x         = 8'h92; /* -3.75 */
            p8y         = 8'h9d; /* -2.375 */
            p8c_exp       = 8'h78; /* 8.0 */
        
        #10;
            /* test #20 */
            p8x         = 8'hfa; /* -0.09375 */
            p8y         = 8'h79; /* 10.0 */
            p8c_exp       = 8'hc4; /* -0.9375 */
        
        #10;
            /* test #21 */
            p8x         = 8'h64; /* 2.5 */
            p8y         = 8'he0; /* -0.5 */
            p8c_exp       = 8'hb8; /* -1.25 */
        
        #10;
            /* test #22 */
            p8x         = 8'h26; /* 0.59375 */
            p8y         = 8'ha3; /* -1.90625 */
            p8c_exp       = 8'hbc; /* -1.125 */
        
        #10;
            /* test #23 */
            p8x         = 8'h92; /* -3.75 */
            p8y         = 8'ha6; /* -1.8125 */
            p8c_exp       = 8'h76; /* 7.0 */
        
        #10;
            /* test #24 */
            p8x         = 8'h1d; /* 0.453125 */
            p8y         = 8'h50; /* 1.5 */
            p8c_exp       = 8'h2c; /* 0.6875 */
        
        #10;
            /* test #25 */
            p8x         = 8'he5; /* -0.421875 */
            p8y         = 8'h92; /* -3.75 */
            p8c_exp       = 8'h53; /* 1.59375 */
        
        #10;
            /* test #26 */
            p8x         = 8'hae; /* -1.5625 */
            p8y         = 8'he4; /* -0.4375 */
            p8c_exp       = 8'h2c; /* 0.6875 */
        
        #10;
            /* test #27 */
            p8x         = 8'ha3; /* -1.90625 */
            p8y         = 8'h53; /* 1.59375 */
            p8c_exp       = 8'h98; /* -3.0 */
        
        #10;
            /* test #28 */
            p8x         = 8'h3f; /* 0.984375 */
            p8y         = 8'hb2; /* -1.4375 */
            p8c_exp       = 8'hb3; /* -1.40625 */
        
        #10;
            /* test #29 */
            p8x         = 8'h1d; /* 0.453125 */
            p8y         = 8'hca; /* -0.84375 */
            p8c_exp       = 8'he8; /* -0.375 */
        
        #10;
            /* test #30 */
            p8x         = 8'hc1; /* -0.984375 */
            p8y         = 8'h18; /* 0.375 */
            p8c_exp       = 8'he8; /* -0.375 */
        
        #10;
            /* test #31 */
            p8x         = 8'h27; /* 0.609375 */
            p8y         = 8'h88; /* -8.0 */
            p8c_exp       = 8'h8e; /* -5.0 */
        
        #10;
            /* test #32 */
            p8x         = 8'h73; /* 5.5 */
            p8y         = 8'h7a; /* 12.0 */
            p8c_exp       = 8'h7f; /* 64.0 */
        
        #10;
            /* test #33 */
            p8x         = 8'h30; /* 0.75 */
            p8y         = 8'hf8; /* -0.125 */
            p8c_exp       = 8'hfa; /* -0.09375 */
        
        #10;
            /* test #34 */
            p8x         = 8'h6f; /* 3.875 */
            p8y         = 8'h3a; /* 0.90625 */
            p8c_exp       = 8'h6c; /* 3.5 */
        
        #10;
            /* test #35 */
            p8x         = 8'h09; /* 0.140625 */
            p8y         = 8'h57; /* 1.71875 */
            p8c_exp       = 8'h0f; /* 0.234375 */
        
        #10;
            /* test #36 */
            p8x         = 8'hfe; /* -0.03125 */
            p8y         = 8'h77; /* 7.5 */
            p8c_exp       = 8'hf1; /* -0.234375 */
        
        #10;
            /* test #37 */
            p8x         = 8'ha0; /* -2.0 */
            p8y         = 8'h97; /* -3.125 */
            p8c_exp       = 8'h74; /* 6.0 */
        
        #10;
            /* test #38 */
            p8x         = 8'h60; /* 2.0 */
            p8y         = 8'h2a; /* 0.65625 */
            p8c_exp       = 8'h4a; /* 1.3125 */
        
        #10;
            /* test #39 */
            p8x         = 8'hb4; /* -1.375 */
            p8y         = 8'h6b; /* 3.375 */
            p8c_exp       = 8'h8f; /* -4.5 */
        
        #10;
            /* test #40 */
            p8x         = 8'h9e; /* -2.25 */
            p8y         = 8'h49; /* 1.28125 */
            p8c_exp       = 8'h99; /* -2.875 */
        
        #10;
            /* test #41 */
            p8x         = 8'h81; /* -64.0 */
            p8y         = 8'hbd; /* -1.09375 */
            p8c_exp       = 8'h7f; /* 64.0 */
        
        #10;
            /* test #42 */
            p8x         = 8'hab; /* -1.65625 */
            p8y         = 8'h48; /* 1.25 */
            p8c_exp       = 8'h9f; /* -2.125 */
        
        #10;
            /* test #43 */
            p8x         = 8'h95; /* -3.375 */
            p8y         = 8'h88; /* -8.0 */
            p8c_exp       = 8'h7d; /* 24.0 */
        
        #10;
            /* test #44 */
            p8x         = 8'h10; /* 0.25 */
            p8y         = 8'h82; /* -32.0 */
            p8c_exp       = 8'h88; /* -8.0 */
        
        #10;
            /* test #45 */
            p8x         = 8'h87; /* -10.0 */
            p8y         = 8'hfc; /* -0.0625 */
            p8c_exp       = 8'h28; /* 0.625 */
        
        #10;
            /* test #46 */
            p8x         = 8'h73; /* 5.5 */
            p8y         = 8'hdb; /* -0.578125 */
            p8c_exp       = 8'h97; /* -3.125 */
        
        #10;
            /* test #47 */
            p8x         = 8'h17; /* 0.359375 */
            p8y         = 8'h43; /* 1.09375 */
            p8c_exp       = 8'h19; /* 0.390625 */
        
        #10;
            /* test #48 */
            p8x         = 8'hd7; /* -0.640625 */
            p8y         = 8'h6d; /* 3.625 */
            p8c_exp       = 8'h9d; /* -2.375 */
        
        #10;
            /* test #49 */
            p8x         = 8'h41; /* 1.03125 */
            p8y         = 8'hbe; /* -1.0625 */
            p8c_exp       = 8'hbd; /* -1.09375 */
        
        #10;
            /* test #50 */
            p8x         = 8'ha1; /* -1.96875 */
            p8y         = 8'h34; /* 0.8125 */
            p8c_exp       = 8'had; /* -1.59375 */
        
        #10;
            /* test #51 */
            p8x         = 8'hec; /* -0.3125 */
            p8y         = 8'h6c; /* 3.5 */
            p8c_exp       = 8'hbd; /* -1.09375 */
        
        #10;


        $finish;
    end

endmodule
// synopsys translate_on
