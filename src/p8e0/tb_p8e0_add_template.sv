/*

[https://github.com/zachjs/sv2v](https://github.com/zachjs/sv2v)
sv2v -DPROBE_SIGNALS  p8e0_add.sv p8e0_pkg.sv tb_p8e0_add.sv > out.v
iverilog out.v && ./a.out
*/

// synopsys translate_off

import p8e0_pkg::*;

module tb_p8e0_add;

    localparam ZERO = 'h0;
    localparam P8_NAR = 8'h80;

    logic   [7:0]   a, b;
    wire    [7:0]   ui_a, ui_b;
    
    logic   [100:0] a_ascii, b_ascii, z_ascii;

    wire    [7:0]   z;
    wire            is_zero;
    wire            is_nar;

    wire    [7:0]   k_a, k_b;
    wire    [7:0]   frac_a, frac_b;
    wire    [7:0]   k_c;
    wire    [15:0]  frac16;
    wire            rcarry;

    p8e0_add p8e0_add_inst(
        .a      (a),
        .b      (b),
        .is_zero(is_zero),
        .is_nar (is_nar),
        .z      (z)
    );

    logic [7:0]     z_exp;
    logic           diff_z;



    integer         test_no;


    always_comb begin
        diff_z = diff(z, z_exp);
    end

    initial begin
        $dumpfile("tb_p8e0_add.vcd");
        $display("probe NOT defined");
        $dumpvars(0, tb_p8e0_add);
    end


    initial begin
                
                

    /*{add stuff here}*/


    end
endmodule
// synopsys translate_on
