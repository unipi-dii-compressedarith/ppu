/*
 *  Fri Nov 12 18:00:09 CET 2021
 *
 *  p8e0_mul
 *
 *  ===================================
 *  notes:
 *  Wed Nov 17 18:55:24 CET 2021
 *     - todo: fix inferred latches 
 *
 *
 *  $ which sv2v
 *  ~/Documents/dev/sv2v/bin/sv2v  (https://github.com/zachjs/sv2v)
 *
 *  sv2v p8e0_mul.sv p8e0_pkg.sv > out.v && yosys -p "synth_intel -family max10 -top p8e0_mul -vqm p8e0_mul.vqm" out.v > yosys_intel.out
 *  sv2v p8e0_mul.sv p8e0_pkg.sv > out.v && yosys -p "synth_xilinx -edif p8e0_mul.edif -top p8e0_mul" out.v > yosys_xilinx.out
 *  iverilog -D POST_IMPL -o verif_post -s p8e0_mul p8e0_mul.sv  $(yosys-config --datdir/intel/max10/cells_sim.v) && vvp -N verif_post
 */

import p8e0_pkg::*;

module p8e0_mul(
        input        [7:0]    a,
        input        [7:0]    b,
`ifdef PROBE_SIGNALS
        output logic [7:0]    ui_a,   ui_b,
        output logic [7:0]    k_a,    k_b,
        output logic [7:0]    frac_a, frac_b,
        output logic [7:0]    k_c,
        output logic [15:0]   frac16,
        output logic          rcarry,
`endif
        output /* wire */     is_zero,
        output    wire        is_nar,
        output logic [7:0]    z
    );

    logic sign_a, sign_b, sign_z;

`ifndef PROBE_SIGNALS
    logic [7:0]  ui_a, ui_b;
    logic [7:0]  k_a,    k_b;
    logic [7:0]  frac_a, frac_b;

    logic [7:0]  k_c;
    logic [15:0] frac16;

    logic        rcarry;
`endif

    logic [7:0] frac;
    logic       bits_more;
    
    logic [7:0] u_z;

`ifdef ALTERA_RESERVED_QIS // https://stackoverflow.com/a/59250550/6164816
    always @(*)
`else
    always_comb
`endif
    begin
        //////  z = 0; // always comb does not infer purely combinational logic? 

        if (a == 0 || b == 0 || a == 8'h80 || b == 8'h80) begin
            if (a == 0 || b == 0) begin
                z = 0;
            end else if (a == 8'h80  || b == 8'h80) begin
                z = 8'h80;
            end else begin
                z = 0; // never reached
            end
            ui_a = 0;
            ui_b = 0;
            k_a = 0;
            k_b = 0;
            k_c = 0;
            sign_a = 0;
            sign_b = 0;
            sign_z = 0;
            frac_a = 0; 
            frac_b = 0;
            frac16 = 0;
            rcarry = 0;
            u_z = 0;
            
        end else begin
            sign_a = (a & 8'h80) >> 7;
            sign_b = (b & 8'h80) >> 7;
            sign_z = sign_a ^ sign_b;

            ui_a = sign_a == 0 ? a : c2(a);
            ui_b = sign_b == 0 ? b : c2(b);

            {k_a, frac_a} = separate_bits(ui_a);
            {k_b, frac_b} = separate_bits(ui_b);

            k_c = k_a + k_b;
            frac16 = frac_a * frac_b;
            rcarry = (frac16 & 16'h8000) != 0;

            if (rcarry) begin
                k_c = k_c + 1'b1;
                frac16 = frac16 >> 1;
            end else begin
                k_c = k_c;
                frac16 = frac16;
            end
            
            u_z = calc_ui(k_c, frac16);
            z = from_bits(u_z, sign_z);
        end
    end
    
    assign is_zero = (z == 0     ? 1 : 0);
	assign is_nar =  (z == 8'h80 ? 1 : 0);

endmodule

