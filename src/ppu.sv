// import ariane_pkg::*;

// `define FCVTSP8
// `define FCVTSP160
// `define FCVTSP161
// `define FCVTP8S
// `define FCVTP160S
// `define FCVTP161S
// `define FXCVTHP8
// `define FXCVTP8H
// `define FCVTP8P160
// `define FCVTP160P8
// `define FCVTP8P161
// `define FCVTP161P8
// `define FCVTP160P161
// `define FCVTP161P160


module ppu(i8,i16,i32,u32o,op);
	input logic signed[7:0] i8;
	input logic signed[15:0] i16;
	input logic signed[31:0] i32;
	input logic[7:0] op;
	output logic signed[31:0] u32o;
	logic signed[7:0] f_p8o,fx16_p8o,p160_p8o;
	logic signed[15:0] f_p16o,f_p161o,p8_fx16o,p8_p160o,p161_p160o,p160_p161o,ti16;
	logic signed[31:0] p8_fo,p16_fo,p161_fo;

	fp32_p8 _fp32_p8(.fp32(i32),.p8(f_p8o));
	fp32_p160 _fp32_p160(.fp32(i32),.p16(f_p16o));
	fp32_p161 _fp32_p161(.fp32(i32),.p16(f_p161o));

	p8_fp32 _p8_fp32(.p8(i8),.fp32(p8_fo));
	p160_fp32 _p160_fp32(.p16(i16),.fp32(p16_fo));
	p161_fp32 _p161_fp32(.p16(i16),.fp32(p161_fo));

	fx16_p8 _fx16_p8(.fx16(i16),.p8(fx16_p8o));
	p8_fx16 _p8_fx16(.fx16(p8_fx16o),.p8(i8));
	
	p8_p160 _p8_p160(.p8(i8),.p160(p8_p160o));
	p160_p8 _p160_p8(.p160(i16),.p8(p160_p8o));
	p161_p160 _p161_p160(.p161(i16),.p160(p161_p160o));
	
	p160_p161 _p160_p161(.p160(ti16),.p161(p160_p161o));
	
	always @(*) begin
		case(op)
			// FCVTP8P161[3:0]:	ti16 = {8'b0,i8} << 8;
         	default: 			ti16 = i16; 		
        endcase

        case(op)
			// FCVTSP8: 		u32o = f_p8o;
			// FCVTSP160: 		u32o = f_p16o;
			// FCVTSP161: 		u32o = f_p161o;
			// FCVTP8S: 		u32o = p8_fo;
			// FCVTP160S: 		u32o = p16_fo;
			// FCVTP161S: 		u32o = p161_fo;
			// FXCVTHP8: 		u32o = fx16_p8o;
			// FXCVTP8H: 		u32o = p8_fx16o;
			// FCVTP8P160: 	u32o = p8_p160o;
			// FCVTP160P8: 	u32o = p160_p8o;
			// FCVTP8P161: 	u32o = p160_p161o;
			// FCVTP161P8: 	u32o = (p161_p160o >> 8);
			// FCVTP160P161: 	u32o = p160_p161o;
			// FCVTP161P160: 	u32o = p161_p160o; 		
          default: 			u32o = 0; 		
        endcase
	end
endmodule
