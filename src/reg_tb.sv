module reg_tb;
logic [6:0] regbits,k_val;
logic [2:0] reg_length;
logic [31:0] fp32;
logic [7:0] pos8;
logic [15:0] fx16;
logic enable,clk,reset;

reg8 myreg8(.regbits (regbits),.k_val (k_val),.reg_length (reg_length));
p8_fx16 myfp32p8(.fx16(fx16),.p8(pos8));

initial begin
clk=0;
reset=1;
enable=0;
assign regbits = 7'b1101111;
end
endmodule
