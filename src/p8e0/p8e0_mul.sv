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
 *  iverilog -D PROBE_SIGNALS p8e0_mul.sv
 *  ~/Documents/dev/yosys/yosys -p "synth_intel -family max10 -top p8e0_mul -vqm p8e0_mul.vqm" p8e0_mul.sv > yosys.out
 *  iverilog -D POST_IMPL -o verif_post -s p8e0_mul p8e0_mul.sv  $(yosys-config --datdir/intel/max10/cells_sim.v) && vvp -N verif_post
 */


module p8e0_mul(
        input      [7:0]    a,
        input      [7:0]    b,
`ifdef PROBE_SIGNALS
        output reg [7:0]    ui_a, ui_b,
        output reg [7:0]    k_a,    k_b,
        output reg [7:0]    frac_a, frac_b,
        output reg [7:0]    k_c,
        output reg [15:0]   frac16,
        output reg          rcarry,
`endif
        output              is_zero,
        output              is_nar,
        output reg [7:0]    z
    );

    /*=============== functions ==================*/
    function [7:0] c2(input [7:0] a);
        c2 = ~a + 1'b1;
    endfunction

    function [15:0] separate_bits(
            input [7:0] bits
        );
        begin: _separate_bits
            reg [7:0] k;
            reg [7:0] tmp;
            reg [7:0] reg_length;
            
            // {k, tmp} = separate_bits_tmp(bits);
            tmp = 8'h01;

            casex (bits)
                8'bx0000001: k = -6;
                8'bx000001x: k = -5;
                8'bx00001xx: k = -4;
                8'bx0001xxx: k = -3;
                8'bx001xxxx: k = -2;
                8'bx01xxxxx: k = -1;
                8'bx10xxxxx: k =  0;
                8'bx110xxxx: k =  1;
                8'bx1110xxx: k =  2;
                8'bx11110xx: k =  3;
                8'bx111110x: k =  4;
                8'bx1111110: k =  5;
                8'bx1111111: k =  6;
                default:     k =  8'hxx;
            endcase
            reg_length = 1 + (bits[6] == 1'b1 ? k + 1 : -k);
            ////              ^^^^^^-- first (i.e. leftmost) regime bit

            if (reg_length == 8) reg_length = 7;

            tmp = ((bits << reg_length) & 8'h7f) | 8'h80;

            separate_bits = {k, tmp};
        end
    endfunction

    function [7:0] calc_ui(
            input [7:0] k,
            input [7:0] frac16
        );
        begin: _calc_ui
            reg [7:0] regime;               // 8 bits
            reg       reg_s;                // 1 bit
            reg [7:0] reg_len;              // 8 bits
            
            reg       bits_more;

            {regime, reg_s, reg_len} = calculate_regime(k);
            
            if (reg_len > 6) begin
                if (reg_s)  calc_ui = 8'h7f;
                else        calc_ui = 8'h01;
            end else begin
                frac16 = (frac16 & 16'h3fff) >> reg_len;
                calc_ui = regime + (frac16 >> 8);
                if ((frac16 & 8'h80) != 0) begin
                    bits_more = (frac16 & 8'h7f) != 0;
                    calc_ui = calc_ui + ((calc_ui & 1'b1) | bits_more);
                end
            end
        end
    endfunction

    function [(8+1+8)-1:0] calculate_regime(
            input [7:0] k
        );
        begin: _calculate_regime
            reg [7:0] regime;
            reg       reg_s; 
            reg [7:0] length;

            if (k & 8'h80) begin
            //  └── check if k is negative
                length = -k;
                regime = checked_shr(8'h40, length);
                reg_s = 1'b0;
            end else begin
                length = k + 1;
                regime = 8'h7f - checked_shr(8'h7f, length);
                reg_s = 1'b1;
            end
            calculate_regime = {regime, reg_s, length};
        end
    endfunction

    function [7:0] checked_shr(
            input [7:0] bits,
            input [7:0] rhs   
        );
        checked_shr = bits >> rhs;
    endfunction
    /*============= endfunctions ================*/

    reg sign_a, sign_b, sign_z;

`ifndef PROBE_SIGNALS
    reg [7:0]  ui_a, ui_b;
    reg [7:0]  k_a,    k_b;
    reg [7:0]  frac_a, frac_b;

    reg [7:0]  k_c;
    reg [15:0] frac16;

    reg        rcarry;
`endif


    // calc_ui regs
    reg [7:0] regime;               // 8 bits
    reg       reg_s;                // 1 bit
    reg [7:0] reg_len;              // 8 bits
    // end calc_ui regs

    reg [7:0] frac;
    reg       bits_more;
    
    reg [7:0] u_z;

    always @(*) begin

        if (a == 0 || b == 0 || a == 8'h80 || b == 8'h80) begin
            if (a == 0 || b == 0) begin
                z = 0;
            end else if (a == 8'h80  || b == 8'h80) begin
                z = 8'h80;
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
            
            reg_len = 0;
            regime = 0;
            reg_s = 0;

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


            // calc_ui function            
            {regime, reg_s, reg_len} = calculate_regime(k_c);
            if (reg_len > 6) begin
                case (reg_s)
                    1'b1: u_z = 8'h7f;
                    1'b0: u_z = 8'h01;
                endcase
            end else begin
                frac16 = (frac16 & 16'h3fff) >> reg_len;
                u_z = regime + (frac16 >> 8);
                if ((frac16 & 8'h80) != 0) begin
                    bits_more = (frac16 & 8'h7f) != 0;
                    u_z = u_z + ((u_z & 1'b1) | bits_more);
                end
            end
            
            // u_z = calc_ui(k_c, frac16);

            z = sign_z == 0 ? u_z : c2(u_z);
        end
    end

    assign is_zero = z == 0   ? 1 : 0;
    assign is_nar  = z == 8'h80 ? 1 : 0;

endmodule

