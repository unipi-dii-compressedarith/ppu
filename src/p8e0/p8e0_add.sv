import p8e0_pkg::*;

module p8e0_add(
        input        [7:0]    a,
        input        [7:0]    b,
        output    wire        is_nar,
        output logic [7:0]    z
    );

    function [7:0] add_mags(
            input [7:0] a,
            input [7:0] b
        );
        begin: _add_mags_fun
            logic           sign;
            logic [7:0]     ui_a, ui_b, ui_a_2, ui_b_2;
            logic [7:0]     k_a, k_b;
            logic [7:0]     frac_a, frac_b;

            logic [15:0]    frac16_a;
            logic [7:0]     shift_right;

            logic           rcarry;
            logic [7:0]     u_z;

            logic [7:0]     seven = 7;
            
            sign = a[7];
            if (sign == 0) begin
                ui_a = a;
                ui_b = b;
            end else begin
                ui_a = c2(a);
                ui_b = c2(b);
            end

            if (ui_a < ui_b) begin
                ui_a_2 = ui_b;
                ui_b_2 = ui_a;
            end else begin
                ui_a_2 = ui_a;
                ui_b_2 = ui_b;
            end

            {k_a, frac_a} = separate_bits(ui_a_2);
            {k_b, frac_b} = separate_bits(ui_b_2);

            frac16_a = frac_a << 7;
            shift_right = k_a - k_b;

            frac16_a = frac16_a + shl(frac_b, seven - shift_right);

            rcarry = (frac16_a & 16'h8000) != 0;
            if (rcarry) begin
                k_a += 1;
                frac16_a >>= 1;
            end else begin
                k_a = k_a;
                frac16_a = frac16_a;
            end
            
            u_z = calc_ui(k_a, frac16_a);
            
            add_mags = from_bits(u_z, sign);
        end
    endfunction;

    function [7:0] sub_mags(
            input [7:0] a,
            input [7:0] b
        );
        begin: _sub_mags_fun
            logic sign;
            logic [7:0] ui_a, ui_b, ui_a_2, ui_b_2;
            logic [7:0] frac_a, frac_b;
            logic [15:0] k_a, k_b;
            logic [15:0] frac16_a, frac16_b;
            logic [7:0] shift_right;
            logic [7:0] z;

            sign = a[7];
            if (sign) begin
                ui_a = c2(a);
                ui_b = b;
            end else begin
                ui_a = a;
                ui_b = c2(b);
            end

            if (ui_a == ui_b) begin
                z = 0;
            end else begin

                if (ui_a < ui_b) begin
                    ui_a_2 = ui_b;
                    ui_b_2 = ui_a;
                    sign = !sign;
                end else begin
                    ui_a_2 = ui_a;
                    ui_b_2 = ui_b;
                    sign = sign;
                end

                {k_a, frac_a} = separate_bits(ui_a);
                frac16_a = frac_a << 7;

                {k_b, frac_b} = separate_bits(ui_b);

                shift_right = k_a - k_b;

                frac16_b = frac_b << 7;

                if (shift_right >= 14) begin
                    z = from_bits(ui_a, sign);
                end else begin
                    frac16_b >>= shift_right;
                end
                frac16_a -= frac16_b;


            end
            sub_mags = 0;
        end
    endfunction;

    always_comb begin
        if (a == 0 || b == 0) begin
            z = a | b;
        end else if (a == 8'h80 || b == 8'h80) begin
            z = 8'h80;
        end else begin
            if (((a ^ b) & 8'h80) == 0) begin
                z = add_mags(a, b);
            end else begin
                z = sub_mags(a, b);
            end
        end
    end

	assign is_nar =  (z == 8'h80 ? 1 : 0);

endmodule