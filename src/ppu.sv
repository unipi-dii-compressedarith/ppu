module ppu(i8,i16,i32,u32o,op);
	input logic signed[7:0] i8;
	input logic signed[15:0] i16;
	input logic signed[31:0] i32;
	input logic[2:0] op;
	output logic signed[31:0] u32o;
	logic signed[7:0] f_p8o,fx16_p8o;
	logic signed[15:0] f_p16o,f_p161o,p8_fx16o;
	logic signed[31:0] p8_fo,p16_fo,p161_fo;

	fp32_p8 _fp32_p8(.fp32(i32),.p8(f_p8o));
	fp32_p160 _fp32_p160(.fp32(i32),.p16(f_p16o));
	fp32_p161 _fp32_p161(.fp32(i32),.p16(f_p161o));

	p8_fp32 _p8_fp32(.p8(i8),.fp32(p8_fo));
	p160_fp32 _p160_fp32(.p16(i16),.fp32(p16_fo));
	p161_fp32 _p161_fp32(.p16(i16),.fp32(p161_fo));

	fx16_p8 _fx16_p8(.fx16(i16),.p8(fx16_p8o));
	p8_fx16 p8_fx16(.fx16(p8_fx16o),.p8(i8));
	
	always_comb begin
        case(op)
          3'b000    : u32o = f_p16o; 		
          3'b001    : u32o = f_p161o; 		
          3'b010    : u32o = p8_fx16o; 		
          3'b011    : u32o = p8_fo; 		
          3'b100    : u32o = p16_fo; 		
          3'b101    : u32o = p161_fo; 	
          3'b110    : u32o = f_p8o; 		
          3'b111    : u32o = fx16_p8o; 		
          default  : u32o = 0; 		
        endcase
	end
endmodule
