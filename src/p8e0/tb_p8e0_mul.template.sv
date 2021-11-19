
// iverilog -g2012 -DPROBE_SIGNALS p8e0_mul.sv tb_p8e0_mul.sv && ./a.out

// synopsys translate_off                   // <- include guards for quartus (et al.) so that he ingores this
module tb_p8e0_mul;

    localparam ZERO = 'h0;
    localparam P8_NAR = 8'h80;
    /// localparam UNDEFINED = 'hz; // generic, no length specified.

    function diff(
            input [7:0] reference,
            input [7:0] expected
        );
        diff = reference === expected ? 0 : 1'bx;
    endfunction

    logic  [7:0]  a, b;
    wire [7:0]  ui_a, ui_b;
    
    logic  [100:0] a_ascii, b_ascii, z_ascii;

    wire [7:0]  z;
    wire        is_zero;
    wire        is_nar;

    wire [7:0]  k_a, k_b;
    wire [7:0]  frac_a, frac_b;
    wire [7:0]  k_c;
    wire [15:0] frac16;
    wire        rcarry;

    p8e0_mul p8e0_mul_inst(
        .a      (a),
        .b      (b),
`ifdef PROBE_SIGNALS
        .ui_a   (ui_a),
        .ui_b   (ui_b),
        .k_a    (k_a),
        .k_b    (k_b),
        .frac_a (frac_a),
        .frac_b (frac_b),
        .k_c    (k_c),
        .rcarry (rcarry),
        .frac16 (frac16),
`endif
        .is_zero(is_zero),
        .is_nar (is_nar),
        .z      (z)
    );

    logic [7:0] z_exp;
    logic diff_z;


// `ifdef PROBE_SIGNALS
    logic [7:0] ui_a_exp, ui_b_exp;
    logic [7:0] k_a_exp, k_b_exp, k_c_exp;
    
    logic rcarry_exp;

    logic [7:0] frac_a_exp, frac_b_exp;
    logic [15:0] frac16_exp;

    logic diff_ui_a, diff_ui_b,
        diff_k_a, diff_k_b, diff_k_c,
        diff_rcarry,
        diff_frac_a, diff_frac_b,
        diff_frac16;

    integer test_no;
        
// `endif

    always_comb begin
        diff_z   = diff(z, z_exp);
`ifdef PROBE_SIGNALS
        diff_ui_a = diff(ui_a, ui_a_exp);
        diff_ui_b = diff(ui_b, ui_b_exp);
        diff_k_a = diff(k_a, k_a_exp);
        diff_k_b = diff(k_b, k_b_exp);
        diff_k_c = diff(k_c, k_c_exp);
        diff_rcarry = diff(rcarry, rcarry_exp);
        diff_frac_a = diff(frac_a, frac_a_exp);
        diff_frac_b = diff(frac_b, frac_b_exp);
        diff_frac16 = diff(frac16, frac16_exp);
`endif
    end

    initial begin
`ifdef PROBE_SIGNALS
        $dumpfile("tb_p8e0_mul.vcd");
        $display("probe defined");
`else
        $dumpfile("tb_p8e0_mul_noprobe.vcd");
        $display("probe NOT defined");
`endif
        $dumpvars(0, tb_p8e0_mul);
    end

    initial begin
                

    /*{add stuff here}*/


    end
endmodule
// synopsys translate_on
