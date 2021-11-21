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

    function diff(
            input [7:0] reference,
            input [7:0] expected
        );
        diff = reference === expected ? 0 : 1'bx;
    endfunction

    logic signed[7:0] p8x,p8y;
    wire signed [7:0] p8c;

    integer test_no;
    reg [7:0] p8x_exp, p8y_exp, p8c_exp;
    reg [100:0] p8x_ascii, p8y_ascii, p8c_ascii;

    logic diff_p8c;

    sum8 sum8_inst(.*);

    always_comb begin
        diff_p8c   = diff(p8c, p8c_exp);
    end

    initial begin
        $dumpfile("sum8_tb.vcd");
        $dumpvars(0, sum8_tb);
    
                    test_no =   1;
                    p8x =         8'h7a; /* 12.0 */
                    p8y =         8'h58; /* 1.75 */
                    p8x_ascii =   "12.0";
                    p8y_ascii =   "1.75";
                    p8c_exp      = 8'h7b; /* 14.0 */
                    p8c_ascii    = "14.0";
        #10;
        
                    test_no =   2;
                    p8x =         8'h00; /* 0.0 */
                    p8y =         8'h03; /* 0.046875 */
                    p8x_ascii =   "0.0";
                    p8y_ascii =   "0.046875";
                    p8c_exp      = 8'h03; /* 0.046875 */
                    p8c_ascii    = "0.046875";
        #10;
        
                    test_no =   3;
                    p8x =         8'h80; /* nan */
                    p8y =         8'h90; /* -4.0 */
                    p8x_ascii =   "nan";
                    p8y_ascii =   "-4.0";
                    p8c_exp      = 8'h80; /* nan */
                    p8c_ascii    = "nan";
        #10;
        
                    test_no =   4;
                    p8x =         8'h3c; /* 0.9375 */
                    p8y =         8'h3b; /* 0.921875 */
                    p8x_ascii =   "0.9375";
                    p8y_ascii =   "0.921875";
                    p8c_exp      = 8'h5c; /* 1.875 */
                    p8c_ascii    = "1.875";
        #10;
        
                    test_no =   5;
                    p8x =         8'h97; /* -3.125 */
                    p8y =         8'he7; /* -0.390625 */
                    p8x_ascii =   "-3.125";
                    p8y_ascii =   "-0.390625";
                    p8c_exp      = 8'h94; /* -3.5 */
                    p8c_ascii    = "-3.5";
        #10;
        
                    test_no =   6;
                    p8x =         8'h8b; /* -6.5 */
                    p8y =         8'h56; /* 1.6875 */
                    p8x_ascii =   "-6.5";
                    p8y_ascii =   "1.6875";
                    p8c_exp      = 8'h8e; /* -5.0 */
                    p8c_ascii    = "-5.0";
        #10;
        
                    test_no =   7;
                    p8x =         8'h21; /* 0.515625 */
                    p8y =         8'hae; /* -1.5625 */
                    p8x_ascii =   "0.515625";
                    p8y_ascii =   "-1.5625";
                    p8c_exp      = 8'hbe; /* -1.0625 */
                    p8c_ascii    = "-1.0625";
        #10;
        
                    test_no =   8;
                    p8x =         8'h5e; /* 1.9375 */
                    p8y =         8'hea; /* -0.34375 */
                    p8x_ascii =   "1.9375";
                    p8y_ascii =   "-0.34375";
                    p8c_exp      = 8'h53; /* 1.59375 */
                    p8c_ascii    = "1.59375";
        #10;
        
                    test_no =   9;
                    p8x =         8'hea; /* -0.34375 */
                    p8y =         8'hed; /* -0.296875 */
                    p8x_ascii =   "-0.34375";
                    p8y_ascii =   "-0.296875";
                    p8c_exp      = 8'hd7; /* -0.640625 */
                    p8c_ascii    = "-0.640625";
        #10;
        
                    test_no =   10;
                    p8x =         8'h9a; /* -2.75 */
                    p8y =         8'h07; /* 0.109375 */
                    p8x_ascii =   "-2.75";
                    p8y_ascii =   "0.109375";
                    p8c_exp      = 8'h9b; /* -2.625 */
                    p8c_ascii    = "-2.625";
        #10;
        
                    test_no =   11;
                    p8x =         8'h79; /* 10.0 */
                    p8y =         8'hdb; /* -0.578125 */
                    p8x_ascii =   "10.0";
                    p8y_ascii =   "-0.578125";
                    p8c_exp      = 8'h79; /* 10.0 */
                    p8c_ascii    = "10.0";
        #10;
        
                    test_no =   12;
                    p8x =         8'ha0; /* -2.0 */
                    p8y =         8'h47; /* 1.21875 */
                    p8x_ascii =   "-2.0";
                    p8y_ascii =   "1.21875";
                    p8c_exp      = 8'hce; /* -0.78125 */
                    p8c_ascii    = "-0.78125";
        #10;
        
                    test_no =   13;
                    p8x =         8'h94; /* -3.5 */
                    p8y =         8'h9b; /* -2.625 */
                    p8x_ascii =   "-3.5";
                    p8y_ascii =   "-2.625";
                    p8c_exp      = 8'h8c; /* -6.0 */
                    p8c_ascii    = "-6.0";
        #10;
        
                    test_no =   14;
                    p8x =         8'h10; /* 0.25 */
                    p8y =         8'hab; /* -1.65625 */
                    p8x_ascii =   "0.25";
                    p8y_ascii =   "-1.65625";
                    p8c_exp      = 8'hb3; /* -1.40625 */
                    p8c_ascii    = "-1.40625";
        #10;
        
                    test_no =   15;
                    p8x =         8'h9b; /* -2.625 */
                    p8y =         8'hb2; /* -1.4375 */
                    p8x_ascii =   "-2.625";
                    p8y_ascii =   "-1.4375";
                    p8c_exp      = 8'h90; /* -4.0 */
                    p8c_ascii    = "-4.0";
        #10;
        
                    test_no =   16;
                    p8x =         8'h03; /* 0.046875 */
                    p8y =         8'h29; /* 0.640625 */
                    p8x_ascii =   "0.046875";
                    p8y_ascii =   "0.640625";
                    p8c_exp      = 8'h2c; /* 0.6875 */
                    p8c_ascii    = "0.6875";
        #10;
        
                    test_no =   17;
                    p8x =         8'he8; /* -0.375 */
                    p8y =         8'hf3; /* -0.203125 */
                    p8x_ascii =   "-0.375";
                    p8y_ascii =   "-0.203125";
                    p8c_exp      = 8'hdb; /* -0.578125 */
                    p8c_ascii    = "-0.578125";
        #10;
        
                    test_no =   18;
                    p8x =         8'hd6; /* -0.65625 */
                    p8y =         8'hdc; /* -0.5625 */
                    p8x_ascii =   "-0.65625";
                    p8y_ascii =   "-0.5625";
                    p8c_exp      = 8'hb9; /* -1.21875 */
                    p8c_ascii    = "-1.21875";
        #10;
        
                    test_no =   19;
                    p8x =         8'h78; /* 8.0 */
                    p8y =         8'h53; /* 1.59375 */
                    p8x_ascii =   "8.0";
                    p8y_ascii =   "1.59375";
                    p8c_exp      = 8'h79; /* 10.0 */
                    p8c_ascii    = "10.0";
        #10;
        
                    test_no =   20;
                    p8x =         8'h42; /* 1.0625 */
                    p8y =         8'h8a; /* -7.0 */
                    p8x_ascii =   "1.0625";
                    p8y_ascii =   "-7.0";
                    p8c_exp      = 8'h8c; /* -6.0 */
                    p8c_ascii    = "-6.0";
        #10;
        
                    test_no =   21;
                    p8x =         8'h8d; /* -5.5 */
                    p8y =         8'hfd; /* -0.046875 */
                    p8x_ascii =   "-5.5";
                    p8y_ascii =   "-0.046875";
                    p8c_exp      = 8'h8d; /* -5.5 */
                    p8c_ascii    = "-5.5";
        #10;
        
                    test_no =   22;
                    p8x =         8'h3b; /* 0.921875 */
                    p8y =         8'h92; /* -3.75 */
                    p8x_ascii =   "0.921875";
                    p8y_ascii =   "-3.75";
                    p8c_exp      = 8'h99; /* -2.875 */
                    p8c_ascii    = "-2.875";
        #10;
        
                    test_no =   23;
                    p8x =         8'h31; /* 0.765625 */
                    p8y =         8'h91; /* -3.875 */
                    p8x_ascii =   "0.765625";
                    p8y_ascii =   "-3.875";
                    p8c_exp      = 8'h97; /* -3.125 */
                    p8c_ascii    = "-3.125";
        #10;
        
                    test_no =   24;
                    p8x =         8'hb7; /* -1.28125 */
                    p8y =         8'h1a; /* 0.40625 */
                    p8x_ascii =   "-1.28125";
                    p8y_ascii =   "0.40625";
                    p8c_exp      = 8'hc8; /* -0.875 */
                    p8c_ascii    = "-0.875";
        #10;
        
                    test_no =   25;
                    p8x =         8'hef; /* -0.265625 */
                    p8y =         8'hb6; /* -1.3125 */
                    p8x_ascii =   "-0.265625";
                    p8y_ascii =   "-1.3125";
                    p8c_exp      = 8'hae; /* -1.5625 */
                    p8c_ascii    = "-1.5625";
        #10;
        
                    test_no =   26;
                    p8x =         8'h8a; /* -7.0 */
                    p8y =         8'ha7; /* -1.78125 */
                    p8x_ascii =   "-7.0";
                    p8y_ascii =   "-1.78125";
                    p8c_exp      = 8'h88; /* -8.0 */
                    p8c_ascii    = "-8.0";
        #10;
        
                    test_no =   27;
                    p8x =         8'hf0; /* -0.25 */
                    p8y =         8'h36; /* 0.84375 */
                    p8x_ascii =   "-0.25";
                    p8y_ascii =   "0.84375";
                    p8c_exp      = 8'h26; /* 0.59375 */
                    p8c_ascii    = "0.59375";
        #10;
        
                    test_no =   28;
                    p8x =         8'h8c; /* -6.0 */
                    p8y =         8'ha2; /* -1.9375 */
                    p8x_ascii =   "-6.0";
                    p8y_ascii =   "-1.9375";
                    p8c_exp      = 8'h88; /* -8.0 */
                    p8c_ascii    = "-8.0";
        #10;
        
                    test_no =   29;
                    p8x =         8'hf7; /* -0.140625 */
                    p8y =         8'hd4; /* -0.6875 */
                    p8x_ascii =   "-0.140625";
                    p8y_ascii =   "-0.6875";
                    p8c_exp      = 8'hcb; /* -0.828125 */
                    p8c_ascii    = "-0.828125";
        #10;
        
                    test_no =   30;
                    p8x =         8'h65; /* 2.625 */
                    p8y =         8'hec; /* -0.3125 */
                    p8x_ascii =   "2.625";
                    p8y_ascii =   "-0.3125";
                    p8c_exp      = 8'h62; /* 2.25 */
                    p8c_ascii    = "2.25";
        #10;
        
                    test_no =   31;
                    p8x =         8'ha3; /* -1.90625 */
                    p8y =         8'h44; /* 1.125 */
                    p8x_ascii =   "-1.90625";
                    p8y_ascii =   "1.125";
                    p8c_exp      = 8'hce; /* -0.78125 */
                    p8c_ascii    = "-0.78125";
        #10;
        
                    test_no =   32;
                    p8x =         8'hdc; /* -0.5625 */
                    p8y =         8'h48; /* 1.25 */
                    p8x_ascii =   "-0.5625";
                    p8y_ascii =   "1.25";
                    p8c_exp      = 8'h2c; /* 0.6875 */
                    p8c_ascii    = "0.6875";
        #10;
        
                    test_no =   33;
                    p8x =         8'h26; /* 0.59375 */
                    p8y =         8'h1f; /* 0.484375 */
                    p8x_ascii =   "0.59375";
                    p8y_ascii =   "0.484375";
                    p8c_exp      = 8'h42; /* 1.0625 */
                    p8c_ascii    = "1.0625";
        #10;
        
                    test_no =   34;
                    p8x =         8'hec; /* -0.3125 */
                    p8y =         8'h10; /* 0.25 */
                    p8x_ascii =   "-0.3125";
                    p8y_ascii =   "0.25";
                    p8c_exp      = 8'hfc; /* -0.0625 */
                    p8c_ascii    = "-0.0625";
        #10;
        
                    test_no =   35;
                    p8x =         8'ha2; /* -1.9375 */
                    p8y =         8'h7b; /* 14.0 */
                    p8x_ascii =   "-1.9375";
                    p8y_ascii =   "14.0";
                    p8c_exp      = 8'h7a; /* 12.0 */
                    p8c_ascii    = "12.0";
        #10;
        
                    test_no =   36;
                    p8x =         8'he1; /* -0.484375 */
                    p8y =         8'hda; /* -0.59375 */
                    p8x_ascii =   "-0.484375";
                    p8y_ascii =   "-0.59375";
                    p8c_exp      = 8'hbe; /* -1.0625 */
                    p8c_ascii    = "-1.0625";
        #10;
        
                    test_no =   37;
                    p8x =         8'h85; /* -14.0 */
                    p8y =         8'ha3; /* -1.90625 */
                    p8x_ascii =   "-14.0";
                    p8y_ascii =   "-1.90625";
                    p8c_exp      = 8'h84; /* -16.0 */
                    p8c_ascii    = "-16.0";
        #10;
        
                    test_no =   38;
                    p8x =         8'h63; /* 2.375 */
                    p8y =         8'hdf; /* -0.515625 */
                    p8x_ascii =   "2.375";
                    p8y_ascii =   "-0.515625";
                    p8c_exp      = 8'h5c; /* 1.875 */
                    p8c_ascii    = "1.875";
        #10;
        
                    test_no =   39;
                    p8x =         8'hbd; /* -1.09375 */
                    p8y =         8'h16; /* 0.34375 */
                    p8x_ascii =   "-1.09375";
                    p8y_ascii =   "0.34375";
                    p8c_exp      = 8'hd0; /* -0.75 */
                    p8c_ascii    = "-0.75";
        #10;
        
                    test_no =   40;
                    p8x =         8'hf2; /* -0.21875 */
                    p8y =         8'h58; /* 1.75 */
                    p8x_ascii =   "-0.21875";
                    p8y_ascii =   "1.75";
                    p8c_exp      = 8'h51; /* 1.53125 */
                    p8c_ascii    = "1.53125";
        #10;
        
                    test_no =   41;
                    p8x =         8'hab; /* -1.65625 */
                    p8y =         8'hcc; /* -0.8125 */
                    p8x_ascii =   "-1.65625";
                    p8y_ascii =   "-0.8125";
                    p8c_exp      = 8'h9c; /* -2.5 */
                    p8c_ascii    = "-2.5";
        #10;
        
                    test_no =   42;
                    p8x =         8'hc6; /* -0.90625 */
                    p8y =         8'h11; /* 0.265625 */
                    p8x_ascii =   "-0.90625";
                    p8y_ascii =   "0.265625";
                    p8c_exp      = 8'hd7; /* -0.640625 */
                    p8c_ascii    = "-0.640625";
        #10;
        
                    test_no =   43;
                    p8x =         8'hf4; /* -0.1875 */
                    p8y =         8'h69; /* 3.125 */
                    p8x_ascii =   "-0.1875";
                    p8y_ascii =   "3.125";
                    p8c_exp      = 8'h68; /* 3.0 */
                    p8c_ascii    = "3.0";
        #10;
        
                    test_no =   44;
                    p8x =         8'h28; /* 0.625 */
                    p8y =         8'h26; /* 0.59375 */
                    p8x_ascii =   "0.625";
                    p8y_ascii =   "0.59375";
                    p8c_exp      = 8'h47; /* 1.21875 */
                    p8c_ascii    = "1.21875";
        #10;
        
                    test_no =   45;
                    p8x =         8'hc2; /* -0.96875 */
                    p8y =         8'h05; /* 0.078125 */
                    p8x_ascii =   "-0.96875";
                    p8y_ascii =   "0.078125";
                    p8c_exp      = 8'hc7; /* -0.890625 */
                    p8c_ascii    = "-0.890625";
        #10;
        
                    test_no =   46;
                    p8x =         8'hfd; /* -0.046875 */
                    p8y =         8'h4b; /* 1.34375 */
                    p8x_ascii =   "-0.046875";
                    p8y_ascii =   "1.34375";
                    p8c_exp      = 8'h4a; /* 1.3125 */
                    p8c_ascii    = "1.3125";
        #10;
        
                    test_no =   47;
                    p8x =         8'h0a; /* 0.15625 */
                    p8y =         8'h6d; /* 3.625 */
                    p8x_ascii =   "0.15625";
                    p8y_ascii =   "3.625";
                    p8c_exp      = 8'h6e; /* 3.75 */
                    p8c_ascii    = "3.75";
        #10;
        
                    test_no =   48;
                    p8x =         8'h4d; /* 1.40625 */
                    p8y =         8'hc4; /* -0.9375 */
                    p8x_ascii =   "1.40625";
                    p8y_ascii =   "-0.9375";
                    p8c_exp      = 8'h1e; /* 0.46875 */
                    p8c_ascii    = "0.46875";
        #10;
        
                    test_no =   49;
                    p8x =         8'hc7; /* -0.890625 */
                    p8y =         8'h6a; /* 3.25 */
                    p8x_ascii =   "-0.890625";
                    p8y_ascii =   "3.25";
                    p8c_exp      = 8'h63; /* 2.375 */
                    p8c_ascii    = "2.375";
        #10;
        
                    test_no =   50;
                    p8x =         8'h07; /* 0.109375 */
                    p8y =         8'h1e; /* 0.46875 */
                    p8x_ascii =   "0.109375";
                    p8y_ascii =   "0.46875";
                    p8c_exp      = 8'h25; /* 0.578125 */
                    p8c_ascii    = "0.578125";
        #10;
        
                    test_no =   51;
                    p8x =         8'h44; /* 1.125 */
                    p8y =         8'h0b; /* 0.171875 */
                    p8x_ascii =   "1.125";
                    p8y_ascii =   "0.171875";
                    p8c_exp      = 8'h4a; /* 1.3125 */
                    p8c_ascii    = "1.3125";
        #10;
        
                    test_no =   52;
                    p8x =         8'he5; /* -0.421875 */
                    p8y =         8'h9a; /* -2.75 */
                    p8x_ascii =   "-0.421875";
                    p8y_ascii =   "-2.75";
                    p8c_exp      = 8'h97; /* -3.125 */
                    p8c_ascii    = "-3.125";
        #10;
        
                    test_no =   53;
                    p8x =         8'h98; /* -3.0 */
                    p8y =         8'h9d; /* -2.375 */
                    p8x_ascii =   "-3.0";
                    p8y_ascii =   "-2.375";
                    p8c_exp      = 8'h8d; /* -5.5 */
                    p8c_ascii    = "-5.5";
        #10;
        
                    test_no =   54;
                    p8x =         8'hb8; /* -1.25 */
                    p8y =         8'hc2; /* -0.96875 */
                    p8x_ascii =   "-1.25";
                    p8y_ascii =   "-0.96875";
                    p8c_exp      = 8'h9e; /* -2.25 */
                    p8c_ascii    = "-2.25";
        #10;
        
                    test_no =   55;
                    p8x =         8'he2; /* -0.46875 */
                    p8y =         8'hcf; /* -0.765625 */
                    p8x_ascii =   "-0.46875";
                    p8y_ascii =   "-0.765625";
                    p8c_exp      = 8'hb8; /* -1.25 */
                    p8c_ascii    = "-1.25";
        #10;
        
                    test_no =   56;
                    p8x =         8'hb6; /* -1.3125 */
                    p8y =         8'h60; /* 2.0 */
                    p8x_ascii =   "-1.3125";
                    p8y_ascii =   "2.0";
                    p8c_exp      = 8'h2c; /* 0.6875 */
                    p8c_ascii    = "0.6875";
        #10;
        
                    test_no =   57;
                    p8x =         8'hc9; /* -0.859375 */
                    p8y =         8'hb7; /* -1.28125 */
                    p8x_ascii =   "-0.859375";
                    p8y_ascii =   "-1.28125";
                    p8c_exp      = 8'h9f; /* -2.125 */
                    p8c_ascii    = "-2.125";
        #10;
        
                    test_no =   58;
                    p8x =         8'h6d; /* 3.625 */
                    p8y =         8'h96; /* -3.25 */
                    p8x_ascii =   "3.625";
                    p8y_ascii =   "-3.25";
                    p8c_exp      = 8'h18; /* 0.375 */
                    p8c_ascii    = "0.375";
        #10;
        
                    test_no =   59;
                    p8x =         8'he4; /* -0.4375 */
                    p8y =         8'h54; /* 1.625 */
                    p8x_ascii =   "-0.4375";
                    p8y_ascii =   "1.625";
                    p8c_exp      = 8'h46; /* 1.1875 */
                    p8c_ascii    = "1.1875";
        #10;
        
                    test_no =   60;
                    p8x =         8'hba; /* -1.1875 */
                    p8y =         8'h8d; /* -5.5 */
                    p8x_ascii =   "-1.1875";
                    p8y_ascii =   "-5.5";
                    p8c_exp      = 8'h8b; /* -6.5 */
                    p8c_ascii    = "-6.5";
        #10;
        
                    test_no =   61;
                    p8x =         8'h93; /* -3.625 */
                    p8y =         8'hf6; /* -0.15625 */
                    p8x_ascii =   "-3.625";
                    p8y_ascii =   "-0.15625";
                    p8c_exp      = 8'h92; /* -3.75 */
                    p8c_ascii    = "-3.75";
        #10;
        
                    test_no =   62;
                    p8x =         8'h71; /* 4.5 */
                    p8y =         8'h81; /* -64.0 */
                    p8x_ascii =   "4.5";
                    p8y_ascii =   "-64.0";
                    p8c_exp      = 8'h81; /* -64.0 */
                    p8c_ascii    = "-64.0";
        #10;
        
                    test_no =   63;
                    p8x =         8'h22; /* 0.53125 */
                    p8y =         8'h3c; /* 0.9375 */
                    p8x_ascii =   "0.53125";
                    p8y_ascii =   "0.9375";
                    p8c_exp      = 8'h4f; /* 1.46875 */
                    p8c_ascii    = "1.46875";
        #10;
        
                    test_no =   64;
                    p8x =         8'h5d; /* 1.90625 */
                    p8y =         8'h09; /* 0.140625 */
                    p8x_ascii =   "1.90625";
                    p8y_ascii =   "0.140625";
                    p8c_exp      = 8'h60; /* 2.0 */
                    p8c_ascii    = "2.0";
        #10;
        
                    test_no =   65;
                    p8x =         8'h18; /* 0.375 */
                    p8y =         8'h4f; /* 1.46875 */
                    p8x_ascii =   "0.375";
                    p8y_ascii =   "1.46875";
                    p8c_exp      = 8'h5b; /* 1.84375 */
                    p8c_ascii    = "1.84375";
        #10;
        
                    test_no =   66;
                    p8x =         8'h09; /* 0.140625 */
                    p8y =         8'h01; /* 0.015625 */
                    p8x_ascii =   "0.140625";
                    p8y_ascii =   "0.015625";
                    p8c_exp      = 8'h0a; /* 0.15625 */
                    p8c_ascii    = "0.15625";
        #10;
        
                    test_no =   67;
                    p8x =         8'hc3; /* -0.953125 */
                    p8y =         8'h13; /* 0.296875 */
                    p8x_ascii =   "-0.953125";
                    p8y_ascii =   "0.296875";
                    p8c_exp      = 8'hd6; /* -0.65625 */
                    p8c_ascii    = "-0.65625";
        #10;
        
                    test_no =   68;
                    p8x =         8'h7e; /* 32.0 */
                    p8y =         8'h1b; /* 0.421875 */
                    p8x_ascii =   "32.0";
                    p8y_ascii =   "0.421875";
                    p8c_exp      = 8'h7e; /* 32.0 */
                    p8c_ascii    = "32.0";
        #10;
        
                    test_no =   69;
                    p8x =         8'h37; /* 0.859375 */
                    p8y =         8'h99; /* -2.875 */
                    p8x_ascii =   "0.859375";
                    p8y_ascii =   "-2.875";
                    p8c_exp      = 8'ha0; /* -2.0 */
                    p8c_ascii    = "-2.0";
        #10;
        
                    test_no =   70;
                    p8x =         8'hee; /* -0.28125 */
                    p8y =         8'h89; /* -7.5 */
                    p8x_ascii =   "-0.28125";
                    p8y_ascii =   "-7.5";
                    p8c_exp      = 8'h88; /* -8.0 */
                    p8c_ascii    = "-8.0";
        #10;
        
                    test_no =   71;
                    p8x =         8'hac; /* -1.625 */
                    p8y =         8'h08; /* 0.125 */
                    p8x_ascii =   "-1.625";
                    p8y_ascii =   "0.125";
                    p8c_exp      = 8'hb0; /* -1.5 */
                    p8c_ascii    = "-1.5";
        #10;
        
                    test_no =   72;
                    p8x =         8'h6f; /* 3.875 */
                    p8y =         8'h32; /* 0.78125 */
                    p8x_ascii =   "3.875";
                    p8y_ascii =   "0.78125";
                    p8c_exp      = 8'h71; /* 4.5 */
                    p8c_ascii    = "4.5";
        #10;
        
                    test_no =   73;
                    p8x =         8'hf6; /* -0.15625 */
                    p8y =         8'h68; /* 3.0 */
                    p8x_ascii =   "-0.15625";
                    p8y_ascii =   "3.0";
                    p8c_exp      = 8'h67; /* 2.875 */
                    p8c_ascii    = "2.875";
        #10;
        
                    test_no =   74;
                    p8x =         8'hd2; /* -0.71875 */
                    p8y =         8'h4a; /* 1.3125 */
                    p8x_ascii =   "-0.71875";
                    p8y_ascii =   "1.3125";
                    p8c_exp      = 8'h26; /* 0.59375 */
                    p8c_ascii    = "0.59375";
        #10;
        
                    test_no =   75;
                    p8x =         8'h6b; /* 3.375 */
                    p8y =         8'h9c; /* -2.5 */
                    p8x_ascii =   "3.375";
                    p8y_ascii =   "-2.5";
                    p8c_exp      = 8'h38; /* 0.875 */
                    p8c_ascii    = "0.875";
        #10;
        
                    test_no =   76;
                    p8x =         8'h81; /* -64.0 */
                    p8y =         8'h43; /* 1.09375 */
                    p8x_ascii =   "-64.0";
                    p8y_ascii =   "1.09375";
                    p8c_exp      = 8'h81; /* -64.0 */
                    p8c_ascii    = "-64.0";
        #10;
        
                    test_no =   77;
                    p8x =         8'h62; /* 2.25 */
                    p8y =         8'h27; /* 0.609375 */
                    p8x_ascii =   "2.25";
                    p8y_ascii =   "0.609375";
                    p8c_exp      = 8'h67; /* 2.875 */
                    p8c_ascii    = "2.875";
        #10;
        
                    test_no =   78;
                    p8x =         8'h92; /* -3.75 */
                    p8y =         8'hb0; /* -1.5 */
                    p8x_ascii =   "-3.75";
                    p8y_ascii =   "-1.5";
                    p8c_exp      = 8'h8e; /* -5.0 */
                    p8c_ascii    = "-5.0";
        #10;
        
                    test_no =   79;
                    p8x =         8'h59; /* 1.78125 */
                    p8y =         8'h0a; /* 0.15625 */
                    p8x_ascii =   "1.78125";
                    p8y_ascii =   "0.15625";
                    p8c_exp      = 8'h5e; /* 1.9375 */
                    p8c_ascii    = "1.9375";
        #10;
        
                    test_no =   80;
                    p8x =         8'h88; /* -8.0 */
                    p8y =         8'hfc; /* -0.0625 */
                    p8x_ascii =   "-8.0";
                    p8y_ascii =   "-0.0625";
                    p8c_exp      = 8'h88; /* -8.0 */
                    p8c_ascii    = "-8.0";
        #10;
        
                    test_no =   81;
                    p8x =         8'h95; /* -3.375 */
                    p8y =         8'h50; /* 1.5 */
                    p8x_ascii =   "-3.375";
                    p8y_ascii =   "1.5";
                    p8c_exp      = 8'ha4; /* -1.875 */
                    p8c_ascii    = "-1.875";
        #10;
        
                    test_no =   82;
                    p8x =         8'h68; /* 3.0 */
                    p8y =         8'h5c; /* 1.875 */
                    p8x_ascii =   "3.0";
                    p8y_ascii =   "1.875";
                    p8c_exp      = 8'h72; /* 5.0 */
                    p8c_ascii    = "5.0";
        #10;
        
                    test_no =   83;
                    p8x =         8'hb1; /* -1.46875 */
                    p8y =         8'h23; /* 0.546875 */
                    p8x_ascii =   "-1.46875";
                    p8y_ascii =   "0.546875";
                    p8c_exp      = 8'hc5; /* -0.921875 */
                    p8c_ascii    = "-0.921875";
    

        #10;
        $finish;
    end

endmodule
// synopsys translate_on
