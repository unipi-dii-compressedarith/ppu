// iverilog -g2012 p8_reg_extr.sv && ./a.out
// ~/Documents/dev/yosys/yosys -p "synth_intel -family max10 -top p8_reg_extr -vqm p8_reg_extr.vqm" p8_reg_extr.sv

module p8_reg_extr (
    input      [7:0] p8,
    output reg [7:0] k_val,
    output reg [7:0] reg_length,
    output reg [7:0] tmp
);

    wire sign_bit;
    reg [7:0] bits;

    assign sign_bit = p8[7];

    always @(*) begin
        case (sign_bit)
            1'b0: bits = p8;
            1'b1: bits = ~p8;
        endcase

        casex (bits)
            8'bx0000001: k_val = -6;
            8'bx000001x: k_val = -5;
            8'bx00001xx: k_val = -4;
            8'bx0001xxx: k_val = -3;
            8'bx001xxxx: k_val = -2;
            8'bx01xxxxx: k_val = -1;

            8'bx10xxxxx: k_val = 0;
            8'bx110xxxx: k_val = 1;
            8'bx1110xxx: k_val = 2;
            8'bx11110xx: k_val = 3;
            8'bx111110x: k_val = 4;
            8'bx1111110: k_val = 5;
            8'bx1111111: k_val = 6;
            default:     k_val = 8'hxx;
        endcase

        reg_length = 1 + (bits[6] == 1'b1 ? k_val + 1 : -k_val);
        ////              ^^^^^^-- first (i.e. leftmost) regime bit

        if (reg_length == 8) reg_length = 7;



        tmp = (p8 << reg_length) & 8'h7f;
    end

endmodule



// synopsys translate_off
module tb_p8_reg_extr;

    reg  [7:0] p8;
    wire [7:0] k_val;
    wire [7:0] reg_length;
    wire [7:0] tmp;

    reg signed [7:0] k_val_exp, reg_length_exp, tmp_exp;

    reg diff_k_val, diff_reg_length, diff_tmp;

    p8_reg_extr p8_reg_extr_inst (.*);

    always @(*) begin
        diff_k_val = (k_val === k_val_exp ? 0 : 8'hxx);
        diff_reg_length = (reg_length === reg_length_exp ? 0 : 8'hxx);
        diff_tmp = (tmp === tmp_exp ? 0 : 8'hxx);
    end

    initial begin
        $dumpfile("tb_p8_reg_extr.vcd");
        $dumpvars(0, tb_p8_reg_extr);
    end

    initial begin
        #2 p8 = 8'b01000000;
        k_val_exp = 0;
        reg_length_exp = 2;
        tmp_exp = 8'b00000000;
        #10 p8 = 8'b01100000;
        k_val_exp = 1;
        reg_length_exp = 3;
        tmp_exp = 8'b00000000;
        #10 p8 = 8'b01111100;
        k_val_exp = 4;
        reg_length_exp = 6;
        tmp_exp = 8'b00000000;
        #10 p8 = 8'b01101110;
        k_val_exp = 1;
        reg_length_exp = 3;
        tmp_exp = 8'b01110000;
        #10 p8 = 8'b01111111;
        k_val_exp = 6;
        reg_length_exp = 7;
        tmp_exp = 8'b00000000;
        #10 p8 = 8'b00111111;
        k_val_exp = -1;
        reg_length_exp = 2;
        tmp_exp = 8'b01111100;
        #10 p8 = 8'b01111110;
        k_val_exp = 5;
        reg_length_exp = 7;
        tmp_exp = 8'b00000000;
        #10 p8 = 8'b00001110;
        k_val_exp = -3;
        reg_length_exp = 4;
        tmp_exp = 8'b01100000;
        #10 p8 = 8'b01101110;
        k_val_exp = 1;
        reg_length_exp = 3;
        tmp_exp = 8'b01110000;
        #10 p8 = 8'b11110110;
        k_val_exp = -3;
        reg_length_exp = 4;
        tmp_exp = 8'b01100000;


        #10;
    end

endmodule
// synopsys translate_on
