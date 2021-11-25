/*

[https://github.com/zachjs/sv2v](https://github.com/zachjs/sv2v)
sv2v -DPROBE_SIGNALS  p8e0_add.sv p8e0_pkg.sv tb_p8e0_add.sv > out.v
iverilog out.v && ./a.out
*/

// synopsys translate_off

`define TEST_BENCH

`ifdef TEST_BENCH

import p8e0_pkg::*;

module tb_p8e0_add;

    localparam ZERO = 'h0;
    localparam P8_NAR = 8'h80;

    logic   [7:0]   a, b;
    wire    [7:0]   ui_a, ui_b;
    
    logic   [100:0] a_ascii, b_ascii, z_ascii;

    wire    [7:0]   z;
    wire            is_nar;

    wire    [7:0]   k_a, k_b;
    wire    [7:0]   frac_a, frac_b;
    wire    [7:0]   k_c;
    wire    [15:0]  frac16;
    wire            rcarry;

    p8e0_add p8e0_add_inst(
        .a      (a),
        .b      (b),

        .is_nar (is_nar),
        .z      (z)
    );

    logic [7:0]     z_exp;
    logic           diff_z;

    logic           inputs_have_same_sign;



    integer         test_no;
    integer         error_count = 0;

    always_comb begin
        diff_z = diff(z, z_exp);

        inputs_have_same_sign = ((a ^ b) & 8'h80) == 0 ? 1 : 0;
    end

    always_comb begin
        #1;
        if (z != z_exp) begin
            error_count += 1;
            $display("error test #%d: %x != %x", test_no, z, z_exp);
        end
    end

    initial begin
        $dumpfile("tb_p8e0_add.vcd");
        $dumpvars(0, tb_p8e0_add);
    end


    initial begin
                
                

    /*{add stuff here}*/

        // $display("ERRORS: %d/%d", error_count, test_no);
    end
endmodule
// synopsys translate_on

`endif