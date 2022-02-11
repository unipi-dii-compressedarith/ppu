/*

Sat Jan 22 16:55:07 CET 2022

cd waveforms

iverilog -g2012 -DTB_UNSIGNED_RECIPROCAL_APPROX -o reciprocal_approx.out \
../src/reciprocal_approx.sv \
&& ./unsigned_reciprocal_approx.out

/// WARNING: two numbers are hardcoded and only work in this case with N = 16.

*/



module reciprocal_approx #(
        parameter N = 16
    )(
        input [N-1:0] i_data,
        output [(3*N)-1:0] o_data
    );

    reg [N-1:0] a, b;
    reg [(2*N)-1:0] c, d;
    reg [(3*N)-1:0] e, out;

    assign a = i_data;

    /*
    hardcoded for SIZE = 16 bits.
    $ python -c 'from fixed2float import to_Fx; N = 16; fp_1_466  = to_Fx(1.466,  1,   N); print(fp_1_466.val)'
    $ python -c 'from fixed2float import to_Fx; N = 16; fp_1_0012 = to_Fx(1.0012, 1, 2*N); print(fp_1_0012.val)'
    */
    wire [N-1:0] fp_1_466 = 48038;
    wire [(2*N)-1:0] fp_1_0012 = 2150060628;


    assign b = fp_1_466 - a;
    assign c = ($signed(a) * $signed(b)) << 1;
    assign d = fp_1_0012 - c;
    assign e = $signed(d) * $signed(b);
    assign out = e << 2;
    
    /// full width output:
    assign o_data = out;

    /// same width output:
    // assign o_data = out[3*N-1: 3*N-1-N];  // (out << 1) >> (2 * N)
endmodule



`ifdef TB_UNSIGNED_RECIPROCAL_APPROX
module tb_reciprocal_approx;

    parameter N = 16;

    reg [N-1:0] i_data;
    wire[N-1:0] o_data;


    reciprocal_approx reciprocal_approx_inst (
        .i_data(i_data),
        .o_data(o_data)
    );


    initial begin
        $dumpfile("tb_reciprocal_approx.vcd");
        $dumpvars(0, tb_reciprocal_approx);
    end

    // python -c "for i in range(0, 1<<16): print(f\"#10;   i_data = 16'h{hex(i)[2:]};\")" | pbcopy 

    initial begin

  i_data = 16'h0;
#10;   i_data = 16'h1;
#10;   i_data = 16'h4e00;
#10;   i_data = 16'h4e01;
#10;   i_data = 16'h4e02;
#10;   i_data = 16'h4e03;
#10;   i_data = 16'h4e04;
#10;   i_data = 16'h4e05;
#10;   i_data = 16'h4e06;
#10;   i_data = 16'h4e07;
#10;   i_data = 16'h4e08;
#10;   i_data = 16'h4e09;
#10;   i_data = 16'h4e0a;
#10;   i_data = 16'h4e0b;
#10;   i_data = 16'h4e0c;
#10;   i_data = 16'h4e0d;
#10;   i_data = 16'h4e0e;
#10;   i_data = 16'h4e0f;
#10;   i_data = 16'h4e10;
#10;   i_data = 16'h4e11;
#10;   i_data = 16'h4e12;
#10;   i_data = 16'h4e13;
#10;   i_data = 16'h4e14;
#10;   i_data = 16'h4e15;
#10;   i_data = 16'h4e16;
#10;   i_data = 16'h4e17;
#10;   i_data = 16'h4e18;
#10;   i_data = 16'h4e19;
#10;   i_data = 16'h4e1a;
#10;   i_data = 16'h4e1b;
#10;   i_data = 16'h4e1c;
#10;   i_data = 16'h4e1d;
#10;   i_data = 16'h4e1e;
#10;   i_data = 16'h4e1f;
#10;   i_data = 16'h4e20;
#10;   i_data = 16'h4e21;
#10;   i_data = 16'h4e22;
#10;   i_data = 16'h4e23;
#10;   i_data = 16'h4e24;
#10;   i_data = 16'h4e25;
#10;   i_data = 16'h4e26;
#10;   i_data = 16'h4e27;
#10;   i_data = 16'h4e28;
#10;   i_data = 16'h4e29;
#10;   i_data = 16'h4e2a;
#10;   i_data = 16'h4e2b;
#10;   i_data = 16'h4e2c;
#10;   i_data = 16'h4e2d;
#10;   i_data = 16'h4e2e;
#10;   i_data = 16'h4e2f;
#10;   i_data = 16'h4e30;
#10;   i_data = 16'h4e31;
#10;   i_data = 16'h4e32;
#10;   i_data = 16'h4e33;
#10;   i_data = 16'h4e34;
#10;   i_data = 16'h4e35;
#10;   i_data = 16'h4e36;
#10;   i_data = 16'h4e37;
#10;   i_data = 16'h4e38;
#10;   i_data = 16'h4e39;
#10;   i_data = 16'h4e3a;
#10;   i_data = 16'h4e3b;
#10;   i_data = 16'h4e3c;
#10;   i_data = 16'h4e3d;
#10;   i_data = 16'h4e3e;
#10;   i_data = 16'h4e3f;
#10;   i_data = 16'h4e40;
#10;   i_data = 16'h4e41;
#10;   i_data = 16'h4e42;
#10;   i_data = 16'h4e43;
#10;   i_data = 16'h4e44;
#10;   i_data = 16'h4e45;
#10;   i_data = 16'h4e46;
#10;   i_data = 16'h4e47;
#10;   i_data = 16'h4e48;
#10;   i_data = 16'h4e49;
#10;   i_data = 16'h4e4a;
#10;   i_data = 16'h4e4b;
#10;   i_data = 16'h4e4c;
#10;   i_data = 16'h4e4d;
#10;   i_data = 16'h4e4e;
#10;   i_data = 16'h4e4f;
#10;   i_data = 16'h4e50;
#10;   i_data = 16'h4e51;
#10;   i_data = 16'h4e52;
#10;   i_data = 16'h4e53;
#10;   i_data = 16'h4e54;
#10;   i_data = 16'h4e55;
#10;   i_data = 16'h4e56;
#10;   i_data = 16'h4e57;
#10;   i_data = 16'h4e58;
#10;   i_data = 16'h4e59;
#10;   i_data = 16'h4e5a;
#10;   i_data = 16'h4e5b;
#10;   i_data = 16'h4e5c;
#10;   i_data = 16'h4e5d;
#10;   i_data = 16'h4e5e;
#10;   i_data = 16'h4e5f;
#10;   i_data = 16'h4e60;
#10;   i_data = 16'h4e61;
#10;   i_data = 16'h4e62;
#10;   i_data = 16'h4e63;
#10;   i_data = 16'h4e64;
#10;   i_data = 16'h4e65;
#10;   i_data = 16'h4e66;
#10;   i_data = 16'h4e67;
#10;   i_data = 16'h4e68;
#10;   i_data = 16'h4e69;
#10;   i_data = 16'h4e6a;
#10;   i_data = 16'h4e6b;
#10;   i_data = 16'h4e6c;
#10;   i_data = 16'h4e6d;
#10;   i_data = 16'h4e6e;
#10;   i_data = 16'h4e6f;
#10;   i_data = 16'h4e70;
#10;   i_data = 16'h4e71;
#10;   i_data = 16'h4e72;
#10;   i_data = 16'h4e73;
#10;   i_data = 16'h4e74;
#10;   i_data = 16'h4e75;
#10;   i_data = 16'h4e76;
#10;   i_data = 16'h4e77;
#10;   i_data = 16'h4e78;
#10;   i_data = 16'h4e79;
#10;   i_data = 16'h4e7a;
#10;   i_data = 16'h4e7b;
#10;   i_data = 16'h4e7c;
#10;   i_data = 16'h4e7d;
#10;   i_data = 16'h4e7e;
#10;   i_data = 16'h4e7f;
#10;   i_data = 16'h4e80;
#10;   i_data = 16'h4e81;
#10;   i_data = 16'h4e82;
#10;   i_data = 16'h4e83;
#10;   i_data = 16'h4e84;
#10;   i_data = 16'h4e85;
#10;   i_data = 16'h4e86;
#10;   i_data = 16'h4e87;
#10;   i_data = 16'h4e88;
#10;   i_data = 16'h4e89;
#10;   i_data = 16'h4e8a;
#10;   i_data = 16'h4e8b;
#10;   i_data = 16'h4e8c;
#10;   i_data = 16'h4e8d;
#10;   i_data = 16'h4e8e;
#10;   i_data = 16'h4e8f;
#10;   i_data = 16'h4e90;
#10;   i_data = 16'h4e91;
#10;   i_data = 16'h4e92;
#10;   i_data = 16'h4e93;
#10;   i_data = 16'h4e94;
#10;   i_data = 16'h4e95;
#10;   i_data = 16'h4e96;
#10;   i_data = 16'h4e97;
#10;   i_data = 16'h4e98;
#10;   i_data = 16'h4e99;
#10;   i_data = 16'h4e9a;
#10;   i_data = 16'h4e9b;
#10;   i_data = 16'h4e9c;
#10;   i_data = 16'h4e9d;
#10;   i_data = 16'h4e9e;
#10;   i_data = 16'h4e9f;
#10;   i_data = 16'h4ea0;
#10;   i_data = 16'h4ea1;
#10;   i_data = 16'h4ea2;
#10;   i_data = 16'h4ea3;
#10;   i_data = 16'h4ea4;
#10;   i_data = 16'h4ea5;
#10;   i_data = 16'h4ea6;
#10;   i_data = 16'h4ea7;
#10;   i_data = 16'h4ea8;
#10;   i_data = 16'h4ea9;
#10;   i_data = 16'h4eaa;
#10;   i_data = 16'h4eab;
#10;   i_data = 16'h4eac;
#10;   i_data = 16'h4ead;
#10;   i_data = 16'h4eae;
#10;   i_data = 16'h4eaf;
#10;   i_data = 16'h4eb0;
#10;   i_data = 16'h4eb1;
#10;   i_data = 16'h4eb2;
#10;   i_data = 16'h4eb3;
#10;   i_data = 16'h4eb4;
#10;   i_data = 16'h4eb5;
#10;   i_data = 16'h4eb6;
#10;   i_data = 16'h4eb7;
#10;   i_data = 16'h4eb8;
#10;   i_data = 16'h4eb9;
#10;   i_data = 16'h4eba;
#10;   i_data = 16'h4ebb;
#10;   i_data = 16'h4ebc;
#10;   i_data = 16'h4ebd;
#10;   i_data = 16'h4ebe;
#10;   i_data = 16'h4ebf;
#10;   i_data = 16'h4ec0;
#10;   i_data = 16'h4ec1;
#10;   i_data = 16'h4ec2;
#10;   i_data = 16'h4ec3;
#10;   i_data = 16'h4ec4;
#10;   i_data = 16'h4ec5;
#10;   i_data = 16'h4ec6;
#10;   i_data = 16'h4ec7;
#10;   i_data = 16'h4ec8;
#10;   i_data = 16'h4ec9;
#10;   i_data = 16'h4eca;
#10;   i_data = 16'h4ecb;
#10;   i_data = 16'h4ecc;
#10;   i_data = 16'h4ecd;
#10;   i_data = 16'h4ece;
#10;   i_data = 16'h4ecf;
#10;   i_data = 16'h4ed0;
#10;   i_data = 16'h4ed1;
#10;   i_data = 16'h4ed2;
#10;   i_data = 16'h4ed3;
#10;   i_data = 16'h4ed4;
#10;   i_data = 16'h4ed5;
#10;   i_data = 16'h4ed6;
#10;   i_data = 16'h4ed7;
#10;   i_data = 16'h4ed8;
#10;   i_data = 16'h4ed9;
#10;   i_data = 16'h4eda;
#10;   i_data = 16'h4edb;
#10;   i_data = 16'h4edc;
#10;   i_data = 16'h4edd;
#10;   i_data = 16'h513b;
#10;   i_data = 16'h513c;
#10;
end

endmodule
`endif
