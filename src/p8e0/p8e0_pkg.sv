package p8e0_pkg;

    function [7:0] c2(input [7:0] a);
        c2 = ~a + 1'b1;
    endfunction

    function [15:0] separate_bits(
            input [7:0] bits
        );
        begin: _separate_bits
            logic [7:0] k;
            logic [7:0] tmp;
            logic [7:0] reg_length;
            logic first_regime_bit;

            first_regime_bit = (bits & 8'h40) >> 6 == 1;

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
                default:     k =  8'hff; // never occurs
            endcase
            
            reg_length = 1 + 
                        (first_regime_bit == 1'b1 ? k + 1 : c2(k));

            if (reg_length == 8) reg_length = 7;                            // <---- is this line unnecessary?

            tmp = ((bits << reg_length) & 8'h7f) | 8'h80;

            separate_bits = {k, tmp};
        end
    endfunction

    /*
    function [7:0] calc_ui(
            input [7:0] k,
            input [7:0] frac16
        );
        begin: _calc_ui
            logic [7:0] regime;               // 8 bits
            logic       reg_s;                // 1 bit
            logic [7:0] reg_len;              // 8 bits
            
            logic       bits_more;

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
    */

    function [(8+1+8)-1:0] calculate_regime(
            input [7:0] k
        );
        begin: _calculate_regime
            logic [7:0] regime;
            logic       reg_s; 
            logic [7:0] length;

            if (k & 8'h80) begin // k is negative
                length = c2(k);
                regime = checked_shr(8'h40, c2(k));
                reg_s = 1'b0;
            end else begin
                length = k + 1;
                regime = 8'h7f - checked_shr(8'h7f, k + 1);
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

    function [7:0] from_bits(
            input [7:0] u_z,
            input       sign_z  
        );
        case (sign_z)
            0: from_bits = u_z;
            1: from_bits = c2(u_z);
        endcase
    endfunction

    function diff(
            input [7:0] reference,
            input [7:0] expected
        );
        diff = reference === expected ? 0 : 1'bx;
        //                └── tests for 1, 0, z and x (https://stackoverflow.com/a/5927857/6164816)
    endfunction

endpackage
