module ppu_ap_top (
	ap_clk,
	ap_rst,
	ap_ce,
	ap_start,
	ap_continue,
	ppu_in1,
	ppu_in2,
	ppu_op,
	ppu_out,
	ap_idle,
	ap_done,
	ap_ready
);
	parameter WORD = 64;
	parameter FSIZE = 32;
	parameter N = 16;
	parameter ES = 2;
	input ap_clk;
	input ap_rst;
	input ap_ce;
	input ap_start;
	input ap_continue;
	input [WORD - 1:0] ppu_in1;
	input [WORD - 1:0] ppu_in2;
	localparam OP_SIZE = 3;
	input [2:0] ppu_op;
	output wire [WORD - 1:0] ppu_out;
	output wire ap_idle;
	output wire ap_done;
	output wire ap_ready;
	ppu_top #(
		.WORD(WORD),
		.FSIZE(FSIZE),
		.N(N),
		.ES(ES)
	) ppu_top_inst(
		.clk(ap_clk),
		.rst(ap_rst),
		.ppu_valid_in(ap_start),
		.ppu_in1(ppu_in1),
		.ppu_in2(ppu_in2),
		.ppu_op(ppu_op),
		.ppu_out(ppu_out),
		.ppu_valid_o(ap_done)
	);
	assign ap_ready = ap_done;
	assign ap_idle = ~ap_start;
endmodule
module ppu_top (
	clk,
	rst,
	ppu_valid_in,
	ppu_in1,
	ppu_in2,
	ppu_op,
	ppu_out,
	ppu_valid_o
);
	parameter WORD = 64;
	parameter FSIZE = 32;
	parameter N = 16;
	parameter ES = 2;
	input clk;
	input rst;
	input ppu_valid_in;
	input [WORD - 1:0] ppu_in1;
	input [WORD - 1:0] ppu_in2;
	localparam OP_SIZE = 3;
	input [2:0] ppu_op;
	output reg [WORD - 1:0] ppu_out;
	output reg ppu_valid_o;
	reg [WORD - 1:0] in1_reg;
	reg [WORD - 1:0] in2_reg;
	reg [2:0] op_reg;
	reg ppu_valid_in_reg;
	wire [WORD:1] sv2v_tmp_ppu_inst_out;
	always @(*) ppu_out = sv2v_tmp_ppu_inst_out;
	wire [1:1] sv2v_tmp_ppu_inst_valid_o;
	always @(*) ppu_valid_o = sv2v_tmp_ppu_inst_valid_o;
	ppu #(
		.WORD(WORD),
		.FSIZE(FSIZE),
		.N(N),
		.ES(ES)
	) ppu_inst(
		.clk(clk),
		.rst(rst),
		.valid_in(ppu_valid_in_reg),
		.in1(in1_reg),
		.in2(in2_reg),
		.op(op_reg),
		.out(sv2v_tmp_ppu_inst_out),
		.valid_o(sv2v_tmp_ppu_inst_valid_o)
	);
	wire [WORD - 1:0] out_reg;
	always @(posedge clk) begin
		ppu_valid_in_reg <= ppu_valid_in;
		in1_reg <= ppu_in1;
		in2_reg <= ppu_in2;
		op_reg <= ppu_op;
	end
endmodule
module ppu (
	clk,
	rst,
	valid_in,
	in1,
	in2,
	op,
	out,
	valid_o
);
	parameter WORD = 64;
	parameter FSIZE = 32;
	parameter N = 16;
	parameter ES = 2;
	input clk;
	input rst;
	input valid_in;
	input [WORD - 1:0] in1;
	input [WORD - 1:0] in2;
	localparam OP_SIZE = 3;
	input [2:0] op;
	output wire [WORD - 1:0] out;
	output wire valid_o;
	wire stall;
	ppu_control_unit ppu_control_unit_inst(
		.clk(clk),
		.rst(rst),
		.valid_i(valid_in),
		.op(op),
		.valid_o(valid_o),
		.stall_o(stall)
	);
	wire [N - 1:0] p1;
	wire [N - 1:0] p2;
	wire [N - 1:0] posit;
	assign p1 = in1[N - 1:0];
	assign p2 = in2[N - 1:0];
	wire [2:0] op_st2;
	localparam MANT_SIZE = N - 2;
	localparam MS = MANT_SIZE;
	localparam RECIPROCATE_MANT_SIZE = 2 * MANT_SIZE;
	localparam RMS = RECIPROCATE_MANT_SIZE;
	localparam MANT_DIV_RESULT_SIZE = MS + RMS;
	localparam FRAC_FULL_SIZE = MANT_DIV_RESULT_SIZE - 2;
	localparam S = $clog2(N);
	localparam TE_SIZE = (ES + 1) + (S + 1);
	wire [((1 + TE_SIZE) + FRAC_FULL_SIZE) - 1:0] float_fir_in;
	localparam FIR_SIZE = (1 + TE_SIZE) + MANT_SIZE;
	wire [FIR_SIZE - 1:0] posit_fir;
	ppu_core_ops #(
		.N(N),
		.ES(ES)
	) ppu_core_ops_inst(
		.clk(clk),
		.rst(rst),
		.p1(p1),
		.p2(p2),
		.op(op),
		.op_st2(op_st2),
		.stall(stall),
		.float_fir(float_fir_in),
		.posit_fir(posit_fir),
		.pout(posit)
	);
	localparam FLOAT_EXP_SIZE_F32 = 8;
	localparam E_I = FLOAT_EXP_SIZE_F32;
	localparam FLOAT_MANT_SIZE_F32 = 23;
	localparam M_I = FLOAT_MANT_SIZE_F32;
	localparam E_II = TE_SIZE;
	localparam M_II = FRAC_FULL_SIZE;
	wire [10:0] EI_wire = E_I;
	wire [10:0] MI_wire = M_I;
	wire [10:0] EII_wire = E_II;
	wire [10:0] MII_wire = M_II;
	wire [31:0] float_fir_out;
	wire __sign = float_fir_out[31];
	wire [TE_SIZE - 1:0] __exp = float_fir_out[M_I + E_II:M_I];
	wire [FRAC_FULL_SIZE - 1:0] __frac;
	generate
		if (M_II <= 32) begin : genblk1
			assign __frac = float_fir_out[22-:M_II];
		end
		else begin : genblk1
			assign __frac = float_fir_out[22:0];
		end
	endgenerate
	assign float_fir_in = {__sign, __exp, __frac};
	wire [FSIZE - 1:0] float_in_st0;
	reg [FSIZE - 1:0] float_in_st1;
	always @(posedge clk)
		if (rst)
			float_in_st1 <= 0;
		else
			float_in_st1 <= float_in_st0;
	wire [FSIZE - 1:0] float_out_st0;
	reg [FSIZE - 1:0] float_out_st1;
	assign float_in_st0 = in1[FSIZE - 1:0];
	always @(posedge clk)
		if (rst)
			float_out_st1 <= 0;
		else
			float_out_st1 <= float_out_st0;
	float_to_fir #(.FSIZE(FSIZE)) float_to_fir_inst(
		.clk(clk),
		.rst(rst),
		.bits(float_in_st1),
		.fir(float_fir_out)
	);
	wire [FSIZE - 1:0] float;
	fir_to_float #(
		.N(N),
		.ES(ES),
		.FSIZE(FSIZE)
	) fir_to_float_inst(
		.clk(clk),
		.rst(rst),
		.fir(posit_fir),
		.float(float_out_st0)
	);
	localparam POSIT_TO_FLOAT = 3'd5;
	assign out = (op_st2 === POSIT_TO_FLOAT ? float_out_st1 : posit);
endmodule
module ppu_core_ops (
	clk,
	rst,
	p1,
	p2,
	op,
	op_st2,
	stall,
	float_fir,
	posit_fir,
	pout
);
	parameter N = 16;
	parameter ES = 2;
	parameter FSIZE = 32;
	input clk;
	input rst;
	input [N - 1:0] p1;
	input [N - 1:0] p2;
	localparam OP_SIZE = 3;
	input [2:0] op;
	output reg [2:0] op_st2;
	input stall;
	localparam MANT_SIZE = N - 2;
	localparam MS = MANT_SIZE;
	localparam RECIPROCATE_MANT_SIZE = 2 * MANT_SIZE;
	localparam RMS = RECIPROCATE_MANT_SIZE;
	localparam MANT_DIV_RESULT_SIZE = MS + RMS;
	localparam FRAC_FULL_SIZE = MANT_DIV_RESULT_SIZE - 2;
	localparam S = $clog2(N);
	localparam TE_SIZE = (ES + 1) + (S + 1);
	input [((1 + TE_SIZE) + FRAC_FULL_SIZE) - 1:0] float_fir;
	localparam FIR_SIZE = (1 + TE_SIZE) + MANT_SIZE;
	output wire [FIR_SIZE - 1:0] posit_fir;
	output wire [N - 1:0] pout;
	wire [2:0] op_st0;
	wire [2:0] op_st1;
	assign op_st0 = op;
	localparam K_SIZE = S + 2;
	wire [K_SIZE - 1:0] k1;
	wire [K_SIZE - 1:0] k2;
	wire [ES - 1:0] exp1;
	wire [ES - 1:0] exp2;
	wire [MANT_SIZE - 1:0] mant1;
	wire [MANT_SIZE - 1:0] mant2;
	wire [(3 * MANT_SIZE) - 1:0] mant_out_ops;
	wire [TE_SIZE - 1:0] te1;
	wire [TE_SIZE - 1:0] te2;
	wire [TE_SIZE - 1:0] te_out_ops;
	wire sign1;
	wire sign2;
	wire [N - 1:0] p1_cond;
	wire [N - 1:0] p2_cond;
	wire is_special_or_trivial;
	wire [N - 1:0] pout_special_or_trivial;
	wire [N:0] special_st0;
	wire [N:0] special_st1;
	reg [N:0] special_st2;
	reg [N:0] special_st3;
	input_conditioning #(.N(N)) input_conditioning(
		.p1_in(p1),
		.p2_in(p2),
		.op(op_st0),
		.p1_out(p1_cond),
		.p2_out(p2_cond),
		.special(special_st0)
	);
	assign is_special_or_trivial = special_st3[0];
	assign pout_special_or_trivial = special_st3 >> 1;
	wire [FIR_SIZE - 1:0] fir1_st0;
	wire [FIR_SIZE - 1:0] fir1_st1;
	wire [FIR_SIZE - 1:0] fir2_st0;
	wire [FIR_SIZE - 1:0] fir2_st1;
	posit_to_fir #(
		.N(N),
		.ES(ES)
	) posit_to_fir1(
		.p_cond(p1_cond),
		.fir(fir1_st0)
	);
	wire [N - 1:0] posit_in_posit_to_fir2;
	localparam POSIT_TO_FLOAT = 3'd5;
	assign posit_in_posit_to_fir2 = (op_st0 == POSIT_TO_FLOAT ? p2 : p2_cond);
	posit_to_fir #(
		.N(N),
		.ES(ES)
	) posit_to_fir2(
		.p_cond(posit_in_posit_to_fir2),
		.fir(fir2_st0)
	);
	assign posit_fir = fir2_st1;
	wire [TE_SIZE - 1:0] ops_te_out;
	wire [FRAC_FULL_SIZE - 1:0] ops_frac_full;
	reg_banks reg_banks_inst(
		.clk(clk),
		.rst(rst),
		.fir1_in(fir1_st0),
		.fir2_in(fir2_st0),
		.op_in(op_st0),
		.special_in(special_st0),
		.stall_i(stall),
		.delay_op(1'b0),
		.fir1_out(fir1_st1),
		.fir2_out(fir2_st1),
		.op_out(op_st1),
		.special_out(special_st1)
	);
	wire sign_out_ops;
	wire [(1 + TE_SIZE) + FRAC_FULL_SIZE:0] ops_out;
	ops #(.N(N)) ops_inst(
		.clk(clk),
		.rst(rst),
		.op(op_st1),
		.fir1(fir1_st1),
		.fir2(fir2_st1),
		.ops_out(ops_out)
	);
	wire frac_truncated;
	wire [N - 1:0] pout_non_special;
	reg [(1 + TE_SIZE) + FRAC_FULL_SIZE:0] ops_wire_st0;
	reg [(1 + TE_SIZE) + FRAC_FULL_SIZE:0] ops_wire_st1;
	localparam FLOAT_TO_POSIT = 3'd4;
	wire [(((1 + TE_SIZE) + FRAC_FULL_SIZE) >= 0 ? ((1 + TE_SIZE) + FRAC_FULL_SIZE) + 1 : 1 - ((1 + TE_SIZE) + FRAC_FULL_SIZE)):1] sv2v_tmp_D3F37;
	assign sv2v_tmp_D3F37 = (op_st1 === FLOAT_TO_POSIT ? {float_fir, 1'b0} : ops_out);
	always @(*) ops_wire_st0 = sv2v_tmp_D3F37;
	fir_to_posit #(
		.N(N),
		.ES(ES),
		.FIR_TOTAL_SIZE((1 + TE_SIZE) + FRAC_FULL_SIZE)
	) fir_to_posit_inst(
		.ops_in(ops_wire_st1),
		.posit(pout_non_special)
	);
	assign pout = (is_special_or_trivial ? pout_special_or_trivial : pout_non_special);
	always @(posedge clk)
		if (rst == 1'b1) begin
			ops_wire_st1 <= 'b0;
			special_st2 <= 'b0;
			special_st3 <= 'b0;
			op_st2 <= 'b0;
		end
		else begin
			ops_wire_st1 <= ops_wire_st0;
			special_st2 <= special_st1;
			special_st3 <= special_st2;
			op_st2 <= op_st1;
		end
endmodule
module posit_to_fir (
	p_cond,
	fir
);
	parameter N = 4;
	parameter ES = 0;
	input [N - 1:0] p_cond;
	localparam MANT_SIZE = N - 2;
	localparam S = $clog2(N);
	localparam TE_SIZE = (ES + 1) + (S + 1);
	localparam FIR_SIZE = (1 + TE_SIZE) + MANT_SIZE;
	output wire [FIR_SIZE - 1:0] fir;
	wire sign;
	wire [TE_SIZE - 1:0] te;
	wire [MANT_SIZE - 1:0] mant;
	posit_decoder #(
		.N(N),
		.ES(ES)
	) posit_decoder_inst(
		.bits(p_cond),
		.sign(sign),
		.te(te),
		.mant(mant)
	);
	assign fir = {sign, te, mant};
endmodule
module fir_to_posit (
	ops_in,
	posit
);
	parameter N = 4;
	parameter ES = 0;
	parameter FIR_TOTAL_SIZE = 43;
	input [FIR_TOTAL_SIZE:0] ops_in;
	output wire [N - 1:0] posit;
	wire [FIR_TOTAL_SIZE - 1:0] fir;
	wire frac_truncated;
	assign {fir, frac_truncated} = ops_in;
	wire sign;
	localparam S = $clog2(N);
	localparam TE_SIZE = (ES + 1) + (S + 1);
	wire [TE_SIZE - 1:0] te;
	localparam MANT_SIZE = N - 2;
	localparam MS = MANT_SIZE;
	localparam RECIPROCATE_MANT_SIZE = 2 * MANT_SIZE;
	localparam RMS = RECIPROCATE_MANT_SIZE;
	localparam MANT_DIV_RESULT_SIZE = MS + RMS;
	localparam FRAC_FULL_SIZE = MANT_DIV_RESULT_SIZE - 2;
	wire [FRAC_FULL_SIZE - 1:0] frac_full;
	assign {sign, te, frac_full} = fir;
	wire [MANT_SIZE - 1:0] frac;
	localparam K_SIZE = S + 2;
	wire [K_SIZE - 1:0] k;
	wire [ES - 1:0] next_exp;
	wire round_bit;
	wire sticky_bit;
	wire k_is_oob;
	wire non_zero_frac_field_size;
	pack_fields #(
		.N(N),
		.ES(ES)
	) pack_fields_inst(
		.frac_full(frac_full),
		.total_exp(te),
		.frac_truncated(frac_truncated),
		.k(k),
		.next_exp(next_exp),
		.frac(frac),
		.round_bit(round_bit),
		.sticky_bit(sticky_bit),
		.k_is_oob(k_is_oob),
		.non_zero_frac_field_size(non_zero_frac_field_size)
	);
	wire [N - 1:0] posit_encoded;
	posit_encoder #(
		.N(N),
		.ES(ES)
	) posit_encoder_inst(
		.sign(1'b0),
		.k(k),
		.exp(next_exp),
		.frac(frac),
		.posit(posit_encoded)
	);
	wire [N - 1:0] posit_pre_sign;
	round_posit #(.N(N)) round_posit_inst(
		.posit(posit_encoded),
		.round_bit(round_bit),
		.sticky_bit(sticky_bit),
		.k_is_oob(k_is_oob),
		.non_zero_frac_field_size(non_zero_frac_field_size),
		.posit_rounded(posit_pre_sign)
	);
	set_sign #(.N(N)) set_sign_inst(
		.posit_in(posit_pre_sign),
		.sign(sign),
		.posit_out(posit)
	);
endmodule
module float_encoder (
	sign,
	exp,
	frac,
	bits
);
	parameter FSIZE = 32;
	input sign;
	localparam FLOAT_EXP_SIZE_F32 = 8;
	input signed [7:0] exp;
	localparam FLOAT_MANT_SIZE_F32 = 23;
	input [22:0] frac;
	output wire [FSIZE - 1:0] bits;
	wire [7:0] exp_bias = 127;
	wire [7:0] exp_biased;
	assign exp_biased = exp + exp_bias;
	assign bits = {sign, exp_biased, frac};
endmodule
module sign_extend (
	posit_total_exponent,
	float_exponent
);
	parameter POSIT_TOTAL_EXPONENT_SIZE = 4;
	parameter FLOAT_EXPONENT_SIZE = 18;
	input [POSIT_TOTAL_EXPONENT_SIZE - 1:0] posit_total_exponent;
	output wire [FLOAT_EXPONENT_SIZE - 1:0] float_exponent;
	assign float_exponent = $signed(posit_total_exponent);
endmodule
module float_to_fir (
	clk,
	rst,
	bits,
	fir
);
	parameter FSIZE = 64;
	input clk;
	input rst;
	input [FSIZE - 1:0] bits;
	localparam FLOAT_EXP_SIZE_F32 = 8;
	localparam FLOAT_MANT_SIZE_F32 = 23;
	output wire [31:0] fir;
	wire sign_st0;
	reg sign_st1;
	wire signed [7:0] exp_st0;
	reg signed [7:0] exp_st1;
	wire [22:0] frac_st0;
	reg [22:0] frac_st1;
	float_decoder #(.FSIZE(FSIZE)) float_decoder_inst(
		.bits(bits),
		.sign(sign_st0),
		.exp(exp_st0),
		.frac(frac_st0)
	);
	assign fir = {sign_st1, exp_st1, frac_st1};
	always @(posedge clk)
		if (rst) begin
			sign_st1 <= 0;
			exp_st1 <= 0;
			frac_st1 <= 0;
		end
		else begin
			sign_st1 <= sign_st0;
			exp_st1 <= exp_st0;
			frac_st1 <= frac_st0;
		end
endmodule
module fir_to_float (
	clk,
	rst,
	fir,
	float
);
	parameter N = 10;
	parameter ES = 1;
	parameter FSIZE = 54;
	input clk;
	input rst;
	localparam MANT_SIZE = N - 2;
	localparam S = $clog2(N);
	localparam TE_SIZE = (ES + 1) + (S + 1);
	localparam FIR_SIZE = (1 + TE_SIZE) + MANT_SIZE;
	input [FIR_SIZE - 1:0] fir;
	output wire [FSIZE - 1:0] float;
	localparam FLOAT_EXP_SIZE_F32 = 8;
	parameter FLOAT_EXP_SIZE = FLOAT_EXP_SIZE_F32;
	localparam FLOAT_MANT_SIZE_F32 = 23;
	parameter FLOAT_MANT_SIZE = FLOAT_MANT_SIZE_F32;
	wire [FIR_SIZE - 1:0] fir_st0;
	reg [FIR_SIZE - 1:0] fir_st1;
	assign fir_st0 = fir;
	always @(posedge clk)
		if (rst)
			fir_st1 <= 0;
		else
			fir_st1 <= fir_st0;
	wire posit_sign;
	wire signed [TE_SIZE - 1:0] posit_te;
	wire [MANT_SIZE - 1:0] posit_frac;
	assign {posit_sign, posit_te, posit_frac} = fir_st1;
	wire float_sign;
	wire signed [FLOAT_EXP_SIZE - 1:0] float_exp;
	wire [FLOAT_MANT_SIZE - 1:0] float_frac;
	assign float_sign = posit_sign;
	sign_extend #(
		.POSIT_TOTAL_EXPONENT_SIZE(TE_SIZE),
		.FLOAT_EXPONENT_SIZE(FLOAT_EXP_SIZE)
	) sign_extend_inst(
		.posit_total_exponent(posit_te),
		.float_exponent(float_exp)
	);
	assign float_frac = posit_frac << ((FLOAT_MANT_SIZE - MANT_SIZE) + 1);
	float_encoder #(.FSIZE(FSIZE)) float_encoder_inst(
		.sign(float_sign),
		.exp(float_exp),
		.frac(float_frac),
		.bits(float)
	);
endmodule
module input_conditioning (
	p1_in,
	p2_in,
	op,
	p1_out,
	p2_out,
	special
);
	parameter N = 4;
	input [N - 1:0] p1_in;
	input [N - 1:0] p2_in;
	localparam OP_SIZE = 3;
	input [2:0] op;
	output wire [N - 1:0] p1_out;
	output wire [N - 1:0] p2_out;
	output wire [N:0] special;
	wire [N - 1:0] _p1;
	wire [N - 1:0] _p2;
	assign _p1 = p1_in;
	localparam SUB = 3'd1;
	function [N - 1:0] c2;
		input [N - 1:0] a;
		c2 = ~a + 1'b1;
	endfunction
	assign _p2 = (op == SUB ? c2(p2_in) : p2_in);
	wire op_is_add_or_sub;
	localparam ADD = 3'd0;
	assign op_is_add_or_sub = (op == ADD) || (op == SUB);
	function [N - 1:0] abs;
		input [N - 1:0] in;
		abs = (in[N - 1] == 0 ? in : c2(in));
	endfunction
	assign {p1_out, p2_out} = (op_is_add_or_sub && (abs(_p2) > abs(_p1)) ? {_p2, _p1} : {_p1, _p2});
	wire [N - 1:0] pout_special_or_trivial;
	handle_special_or_trivial #(.N(N)) handle_special_or_trivial_inst(
		.op(op),
		.p1_in(p1_in),
		.p2_in(p2_in),
		.pout(pout_special_or_trivial)
	);
	wire is_special_or_trivial;
	localparam FLOAT_TO_POSIT = 3'd4;
	localparam NAN = {1'b1, {15 {1'b0}}};
	localparam ZERO = {16 {1'b0}};
	assign is_special_or_trivial = (op === FLOAT_TO_POSIT ? 0 : (((((p1_in == ZERO) || (p1_in == NAN)) || (p2_in == ZERO)) || (p2_in == NAN)) || ((op == SUB) && (p1_in == p2_in))) || ((op == ADD) && (p1_in == c2(p2_in))));
	assign special = {pout_special_or_trivial, is_special_or_trivial};
endmodule
module handle_special_or_trivial (
	op,
	p1_in,
	p2_in,
	pout
);
	parameter N = 10;
	localparam OP_SIZE = 3;
	input [2:0] op;
	input [N - 1:0] p1_in;
	input [N - 1:0] p2_in;
	output wire [N - 1:0] pout;
	wire [N - 1:0] p_out_lut_mul;
	wire [N - 1:0] p_out_lut_add;
	wire [N - 1:0] p_out_lut_sub;
	wire [N - 1:0] p_out_lut_div;
	lut_mul #(.N(N)) lut_mul_inst(
		.p1(p1_in),
		.p2(p2_in),
		.p_out(p_out_lut_mul)
	);
	lut_add #(.N(N)) lut_add_inst(
		.p1(p1_in),
		.p2(p2_in),
		.p_out(p_out_lut_add)
	);
	lut_sub #(.N(N)) lut_sub_inst(
		.p1(p1_in),
		.p2(p2_in),
		.p_out(p_out_lut_sub)
	);
	lut_div #(.N(N)) lut_div_inst(
		.p1(p1_in),
		.p2(p2_in),
		.p_out(p_out_lut_div)
	);
	localparam ADD = 3'd0;
	localparam MUL = 3'd2;
	localparam SUB = 3'd1;
	assign pout = (op == MUL ? p_out_lut_mul : (op == ADD ? p_out_lut_add : (op == SUB ? p_out_lut_sub : p_out_lut_div)));
endmodule
module lut_mul (
	p1,
	p2,
	p_out
);
	parameter N = 8;
	input [N - 1:0] p1;
	input [N - 1:0] p2;
	output reg [N - 1:0] p_out;
	wire [(2 * N) - 1:0] addr;
	assign addr = {p1, p2};
	localparam NAN = {1'b1, {15 {1'b0}}};
	localparam ZERO = {16 {1'b0}};
	always @(*)
		case (p1)
			ZERO: p_out = ((p2 == NAN) || (p2 == ZERO) ? p2 : ZERO);
			NAN: p_out = NAN;
			default: p_out = p2;
		endcase
endmodule
module lut_add (
	p1,
	p2,
	p_out
);
	parameter N = 8;
	input [N - 1:0] p1;
	input [N - 1:0] p2;
	output reg [N - 1:0] p_out;
	localparam NAN = {1'b1, {15 {1'b0}}};
	localparam ZERO = {16 {1'b0}};
	function [N - 1:0] c2;
		input [N - 1:0] a;
		c2 = ~a + 1'b1;
	endfunction
	always @(*)
		case (p1)
			ZERO: p_out = p2;
			NAN: p_out = NAN;
			default: p_out = (p2 == c2(p1) ? ZERO : (p2 == ZERO ? p1 : NAN));
		endcase
endmodule
module lut_sub (
	p1,
	p2,
	p_out
);
	parameter N = 8;
	input [N - 1:0] p1;
	input [N - 1:0] p2;
	output reg [N - 1:0] p_out;
	localparam NAN = {1'b1, {15 {1'b0}}};
	localparam ZERO = {16 {1'b0}};
	function [N - 1:0] c2;
		input [N - 1:0] a;
		c2 = ~a + 1'b1;
	endfunction
	always @(*)
		case (p1)
			ZERO: p_out = ((p2 == ZERO) || (p2 == NAN) ? p2 : c2(p2));
			NAN: p_out = NAN;
			default: p_out = (p2 == p1 ? ZERO : (p2 == ZERO ? p1 : NAN));
		endcase
endmodule
module lut_div (
	p1,
	p2,
	p_out
);
	parameter N = 8;
	input [N - 1:0] p1;
	input [N - 1:0] p2;
	output reg [N - 1:0] p_out;
	localparam NAN = {1'b1, {15 {1'b0}}};
	localparam ZERO = {16 {1'b0}};
	always @(*)
		case (p1)
			ZERO: p_out = ((p2 == NAN) || (p2 == ZERO) ? NAN : ZERO);
			NAN: p_out = NAN;
			default: p_out = NAN;
		endcase
endmodule
module total_exponent (
	k,
	exp,
	total_exp
);
	parameter N = 4;
	parameter ES = 1;
	localparam S = $clog2(N);
	localparam K_SIZE = S + 2;
	input [K_SIZE - 1:0] k;
	input [ES - 1:0] exp;
	localparam TE_SIZE = (ES + 1) + (S + 1);
	output wire [TE_SIZE - 1:0] total_exp;
	assign total_exp = ($signed(k) >= 0 ? (k << ES) + exp : exp - ($signed(-k) << ES));
endmodule
module ops (
	clk,
	rst,
	op,
	fir1,
	fir2,
	ops_out
);
	parameter N = 4;
	input clk;
	input rst;
	localparam OP_SIZE = 3;
	input [2:0] op;
	localparam MANT_SIZE = N - 2;
	localparam ES = 2;
	localparam S = $clog2(N);
	localparam TE_SIZE = 3 + (S + 1);
	localparam FIR_SIZE = (1 + TE_SIZE) + MANT_SIZE;
	input [FIR_SIZE - 1:0] fir1;
	input [FIR_SIZE - 1:0] fir2;
	localparam MS = MANT_SIZE;
	localparam RECIPROCATE_MANT_SIZE = 2 * MANT_SIZE;
	localparam RMS = RECIPROCATE_MANT_SIZE;
	localparam MANT_DIV_RESULT_SIZE = MS + RMS;
	localparam FRAC_FULL_SIZE = MANT_DIV_RESULT_SIZE - 2;
	output wire [(1 + TE_SIZE) + FRAC_FULL_SIZE:0] ops_out;
	wire sign1;
	wire sign2;
	wire [TE_SIZE - 1:0] te1;
	wire [TE_SIZE - 1:0] te2;
	wire [MANT_SIZE - 1:0] mant1;
	wire [MANT_SIZE - 1:0] mant2;
	wire [FRAC_FULL_SIZE - 1:0] frac_out;
	wire sign_out;
	wire [TE_SIZE - 1:0] te_out;
	wire [FRAC_FULL_SIZE - 1:0] frac_full;
	assign {sign1, te1, mant1} = fir1;
	assign {sign2, te2, mant2} = fir2;
	wire frac_truncated;
	core_op #(.N(N)) core_op_inst(
		.clk(clk),
		.rst(rst),
		.op(op),
		.sign1(sign1),
		.sign2(sign2),
		.te1(te1),
		.te2(te2),
		.mant1(mant1),
		.mant2(mant2),
		.te_out_core_op(te_out),
		.frac_out_core_op(frac_out),
		.frac_truncated(frac_truncated)
	);
	sign_decisor sign_decisor(
		.clk(clk),
		.rst(rst),
		.sign1(sign1),
		.sign2(sign2),
		.op(op),
		.sign(sign_out)
	);
	wire [((1 + TE_SIZE) + FRAC_FULL_SIZE) - 1:0] fir_ops_out;
	assign fir_ops_out = {sign_out, te_out, frac_out};
	assign ops_out = {fir_ops_out, frac_truncated};
endmodule
module core_op (
	clk,
	rst,
	op,
	sign1,
	sign2,
	te1,
	te2,
	mant1,
	mant2,
	te_out_core_op,
	frac_out_core_op,
	frac_truncated
);
	parameter N = 10;
	input clk;
	input rst;
	localparam OP_SIZE = 3;
	input [2:0] op;
	input sign1;
	input sign2;
	localparam ES = 2;
	localparam S = $clog2(N);
	localparam TE_SIZE = 3 + (S + 1);
	input [TE_SIZE - 1:0] te1;
	input [TE_SIZE - 1:0] te2;
	localparam MANT_SIZE = N - 2;
	input [MANT_SIZE - 1:0] mant1;
	input [MANT_SIZE - 1:0] mant2;
	output wire [TE_SIZE - 1:0] te_out_core_op;
	localparam MS = MANT_SIZE;
	localparam RECIPROCATE_MANT_SIZE = 2 * MANT_SIZE;
	localparam RMS = RECIPROCATE_MANT_SIZE;
	localparam MANT_DIV_RESULT_SIZE = MS + RMS;
	localparam FRAC_FULL_SIZE = MANT_DIV_RESULT_SIZE - 2;
	output wire [FRAC_FULL_SIZE - 1:0] frac_out_core_op;
	output wire frac_truncated;
	localparam MAX_TE_DIFF = MS;
	localparam MTD = MAX_TE_DIFF;
	localparam MANT_ADD_RESULT_SIZE = (MS + MTD) + 1;
	wire [MANT_ADD_RESULT_SIZE - 1:0] mant_out_add_sub;
	localparam MANT_MUL_RESULT_SIZE = 2 * MS;
	wire [MANT_MUL_RESULT_SIZE - 1:0] mant_out_mul;
	wire [MANT_DIV_RESULT_SIZE - 1:0] mant_out_div;
	wire [TE_SIZE - 1:0] te_out_add_sub;
	wire [TE_SIZE - 1:0] te_out_mul;
	wire [TE_SIZE - 1:0] te_out_div;
	wire frac_truncated_add_sub;
	wire frac_truncated_mul;
	wire frac_truncated_div;
	core_add_sub #(.N(N)) core_add_sub_inst(
		.clk(clk),
		.rst(rst),
		.te1_in(te1),
		.te2_in(te2),
		.mant1_in(mant1),
		.mant2_in(mant2),
		.have_opposite_sign(sign1 ^ sign2),
		.mant_out(mant_out_add_sub),
		.te_out(te_out_add_sub),
		.frac_truncated(frac_truncated_add_sub)
	);
	core_mul #(.N(N)) core_mul_inst(
		.clk(clk),
		.rst(rst),
		.te1(te1),
		.te2(te2),
		.mant1(mant1),
		.mant2(mant2),
		.mant_out(mant_out_mul),
		.te_out(te_out_mul),
		.frac_truncated(frac_truncated_mul)
	);
	core_div #(.N(N)) core_div_inst(
		.clk(clk),
		.rst(rst),
		.te1(te1),
		.te2(te2),
		.mant1(mant1),
		.mant2(mant2),
		.mant_out(mant_out_div),
		.te_out(te_out_div),
		.frac_truncated(frac_truncated_div)
	);
	wire [FRAC_FULL_SIZE - 1:0] mant_out_core_op;
	localparam ADD = 3'd0;
	localparam MUL = 3'd2;
	localparam SUB = 3'd1;
	assign mant_out_core_op = ((op == ADD) || (op == SUB) ? mant_out_add_sub << (FRAC_FULL_SIZE - MANT_ADD_RESULT_SIZE) : (op == MUL ? mant_out_mul << (FRAC_FULL_SIZE - MANT_MUL_RESULT_SIZE) : mant_out_div));
	localparam DIV = 3'd3;
	assign frac_out_core_op = (op == DIV ? mant_out_core_op : mant_out_core_op << 2);
	assign te_out_core_op = ((op == ADD) || (op == SUB) ? te_out_add_sub : (op == MUL ? te_out_mul : te_out_div));
	assign frac_truncated = (op == MUL ? frac_truncated_mul : (op == DIV ? frac_truncated_div : frac_truncated_add_sub));
endmodule
module core_add_sub (
	clk,
	rst,
	te1_in,
	te2_in,
	mant1_in,
	mant2_in,
	have_opposite_sign,
	mant_out,
	te_out,
	frac_truncated
);
	parameter N = 16;
	input clk;
	input rst;
	localparam ES = 2;
	localparam S = $clog2(N);
	localparam TE_SIZE = 3 + (S + 1);
	input [TE_SIZE - 1:0] te1_in;
	input [TE_SIZE - 1:0] te2_in;
	localparam MANT_SIZE = N - 2;
	input [MANT_SIZE - 1:0] mant1_in;
	input [MANT_SIZE - 1:0] mant2_in;
	input have_opposite_sign;
	localparam MS = MANT_SIZE;
	localparam MAX_TE_DIFF = MS;
	localparam MTD = MAX_TE_DIFF;
	localparam MANT_ADD_RESULT_SIZE = (MS + MTD) + 1;
	output wire [MANT_ADD_RESULT_SIZE - 1:0] mant_out;
	output wire [TE_SIZE - 1:0] te_out;
	output wire frac_truncated;
	function [(MANT_SIZE + MAX_TE_DIFF) - 1:0] _c2;
		input [(MANT_SIZE + MAX_TE_DIFF) - 1:0] a;
		_c2 = ~a + 1'b1;
	endfunction
	wire have_opposite_sign_st0;
	reg have_opposite_sign_st1;
	assign have_opposite_sign_st0 = have_opposite_sign;
	wire [TE_SIZE - 1:0] te1;
	wire [TE_SIZE - 1:0] te2_st0;
	reg [TE_SIZE - 1:0] te2_st1;
	wire [MANT_SIZE - 1:0] mant1;
	wire [MANT_SIZE - 1:0] mant2;
	assign {te1, te2_st0} = {te1_in, te2_in};
	assign {mant1, mant2} = {mant1_in, mant2_in};
	wire [TE_SIZE - 1:0] te_diff_st0;
	reg [TE_SIZE - 1:0] te_diff_st1;
	assign te_diff_st0 = $signed(te1) - $signed(te2_st0);
	wire [(MANT_SIZE + MAX_TE_DIFF) - 1:0] mant1_upshifted;
	wire [(MANT_SIZE + MAX_TE_DIFF) - 1:0] mant2_upshifted;
	assign mant1_upshifted = mant1 << MAX_TE_DIFF;
	function [N - 1:0] max;
		input [N - 1:0] a;
		input [N - 1:0] b;
		max = (a >= b ? a : b);
	endfunction
	assign mant2_upshifted = (mant2 << MAX_TE_DIFF) >> max(0, te_diff_st0);
	wire [MANT_ADD_RESULT_SIZE - 1:0] mant_sum_st0;
	reg [MANT_ADD_RESULT_SIZE - 1:0] mant_sum_st1;
	assign mant_sum_st0 = mant1_upshifted + (have_opposite_sign ? _c2(mant2_upshifted) : mant2_upshifted);
	wire [MANT_ADD_RESULT_SIZE - 1:0] mant_out_core_add;
	wire [TE_SIZE - 1:0] te_diff_out_core_add;
	core_add #(.N(N)) core_add_inst(
		.mant(mant_sum_st1),
		.te_diff(te_diff_st1),
		.new_mant(mant_out_core_add),
		.new_te_diff(te_diff_out_core_add),
		.frac_truncated(frac_truncated)
	);
	localparam MANT_SUB_RESULT_SIZE = MS + MTD;
	wire [MANT_SUB_RESULT_SIZE - 1:0] mant_out_core_sub;
	wire [TE_SIZE - 1:0] te_diff_out_core_sub;
	core_sub #(.N(N)) core_sub_inst(
		.mant(mant_sum_st1[MANT_SUB_RESULT_SIZE - 1:0]),
		.te_diff(te_diff_st1),
		.new_mant(mant_out_core_sub),
		.new_te_diff(te_diff_out_core_sub)
	);
	wire [TE_SIZE - 1:0] te_diff_updated;
	assign te_diff_updated = (have_opposite_sign_st1 ? te_diff_out_core_sub : te_diff_out_core_add);
	assign mant_out = (have_opposite_sign_st1 ? {mant_out_core_sub} : mant_out_core_add);
	assign te_out = te2_st1 + te_diff_updated;
	always @(posedge clk)
		if (rst) begin
			te_diff_st1 <= 0;
			mant_sum_st1 <= 0;
			have_opposite_sign_st1 <= 0;
			te2_st1 <= 0;
		end
		else begin
			te_diff_st1 <= te_diff_st0;
			mant_sum_st1 <= mant_sum_st0;
			have_opposite_sign_st1 <= have_opposite_sign_st0;
			te2_st1 <= te2_st0;
		end
endmodule
module core_add (
	mant,
	te_diff,
	new_mant,
	new_te_diff,
	frac_truncated
);
	parameter N = 16;
	localparam MANT_SIZE = N - 2;
	localparam MS = MANT_SIZE;
	localparam MAX_TE_DIFF = MS;
	localparam MTD = MAX_TE_DIFF;
	localparam MANT_ADD_RESULT_SIZE = (MS + MTD) + 1;
	input [MANT_ADD_RESULT_SIZE - 1:0] mant;
	localparam ES = 2;
	localparam S = $clog2(N);
	localparam TE_SIZE = 3 + (S + 1);
	input [TE_SIZE - 1:0] te_diff;
	output wire [MANT_ADD_RESULT_SIZE - 1:0] new_mant;
	output wire [TE_SIZE - 1:0] new_te_diff;
	output wire frac_truncated;
	wire mant_carry;
	assign mant_carry = mant[MANT_ADD_RESULT_SIZE - 1];
	assign new_mant = (mant_carry == 1'b1 ? mant >> 1 : mant);
	assign new_te_diff = (mant_carry == 1'b1 ? te_diff + 1 : te_diff);
	assign frac_truncated = mant_carry && (mant & 1);
endmodule
module core_sub (
	mant,
	te_diff,
	new_mant,
	new_te_diff
);
	parameter N = 4;
	localparam MANT_SIZE = N - 2;
	localparam MS = MANT_SIZE;
	localparam MAX_TE_DIFF = MS;
	localparam MTD = MAX_TE_DIFF;
	localparam MANT_SUB_RESULT_SIZE = MS + MTD;
	input [MANT_SUB_RESULT_SIZE - 1:0] mant;
	localparam ES = 2;
	localparam S = $clog2(N);
	localparam TE_SIZE = 3 + (S + 1);
	input [TE_SIZE - 1:0] te_diff;
	output wire [MANT_SUB_RESULT_SIZE - 1:0] new_mant;
	output wire [TE_SIZE - 1:0] new_te_diff;
	wire [$clog2(MANT_SUB_RESULT_SIZE) - 1:0] leading_zeros;
	wire is_valid;
	lzc #(.NUM_BITS(MANT_SUB_RESULT_SIZE)) lzc_inst(
		.in(mant),
		.out(leading_zeros),
		.vld(is_valid)
	);
	assign new_te_diff = te_diff - leading_zeros;
	assign new_mant = mant << leading_zeros;
endmodule
module core_mul (
	clk,
	rst,
	te1,
	te2,
	mant1,
	mant2,
	mant_out,
	te_out,
	frac_truncated
);
	parameter N = 16;
	input clk;
	input rst;
	localparam ES = 2;
	localparam S = $clog2(N);
	localparam TE_SIZE = 3 + (S + 1);
	input [TE_SIZE - 1:0] te1;
	input [TE_SIZE - 1:0] te2;
	localparam MANT_SIZE = N - 2;
	input [MANT_SIZE - 1:0] mant1;
	input [MANT_SIZE - 1:0] mant2;
	localparam MS = MANT_SIZE;
	localparam MANT_MUL_RESULT_SIZE = 2 * MS;
	output wire [MANT_MUL_RESULT_SIZE - 1:0] mant_out;
	output wire [TE_SIZE - 1:0] te_out;
	output wire frac_truncated;
	wire [TE_SIZE - 1:0] te_sum_st0;
	reg [TE_SIZE - 1:0] te_sum_st1;
	assign te_sum_st0 = te1 + te2;
	localparam MAX_TE_DIFF = MS;
	localparam MTD = MAX_TE_DIFF;
	localparam MANT_SUB_RESULT_SIZE = MS + MTD;
	wire [MANT_SUB_RESULT_SIZE - 1:0] mant_mul;
	wire mant_carry;
	assign mant_carry = mant_mul[MANT_MUL_RESULT_SIZE - 1];
	assign te_out = (mant_carry == 1'b1 ? te_sum_st1 + 1'b1 : te_sum_st1);
	assign mant_out = (mant_carry == 1'b1 ? mant_mul >> 1 : mant_mul);
	assign frac_truncated = mant_carry && (mant_mul & 1);
	always @(posedge clk)
		if (rst)
			te_sum_st1 <= 0;
		else
			te_sum_st1 <= te_sum_st0;
	pp_mul #(
		.M(MANT_SIZE),
		.N(MANT_SIZE)
	) pp_mul_inst(
		.clk(clk),
		.rst(rst),
		.a(mant1),
		.b(mant2),
		.product(mant_mul)
	);
endmodule
module core_div (
	clk,
	rst,
	te1,
	te2,
	mant1,
	mant2,
	mant_out,
	te_out,
	frac_truncated
);
	parameter N = 16;
	input clk;
	input rst;
	localparam ES = 2;
	localparam S = $clog2(N);
	localparam TE_SIZE = 3 + (S + 1);
	input [TE_SIZE - 1:0] te1;
	input [TE_SIZE - 1:0] te2;
	localparam MANT_SIZE = N - 2;
	input [MANT_SIZE - 1:0] mant1;
	input [MANT_SIZE - 1:0] mant2;
	localparam MS = MANT_SIZE;
	localparam RECIPROCATE_MANT_SIZE = 2 * MANT_SIZE;
	localparam RMS = RECIPROCATE_MANT_SIZE;
	localparam MANT_DIV_RESULT_SIZE = MS + RMS;
	output wire [MANT_DIV_RESULT_SIZE - 1:0] mant_out;
	output wire [TE_SIZE - 1:0] te_out;
	output wire frac_truncated;
	wire [MANT_SIZE - 1:0] mant1_st0;
	reg [MANT_SIZE - 1:0] mant1_st1;
	assign mant1_st0 = mant1;
	wire [TE_SIZE - 1:0] te_diff_st0;
	reg [TE_SIZE - 1:0] te_diff_st1;
	assign te_diff_st0 = te1 - te2;
	wire [MANT_DIV_RESULT_SIZE - 1:0] mant_div;
	wire [(3 * MANT_SIZE) - 5:0] mant2_reciprocal;
	initial $display("\n***** NOT using DIV with LUT *****");
	fast_reciprocal #(.SIZE(MANT_SIZE)) fast_reciprocal_inst(
		.fraction(mant2),
		.one_over_fraction(mant2_reciprocal)
	);
	wire [(2 * MANT_SIZE) - 1:0] x1;
	initial $display("***** Using NR *****\n");
	newton_raphson #(.MS(MANT_SIZE)) newton_raphson_inst(
		.clk(clk),
		.rst(rst),
		.num(mant2),
		.x0(mant2_reciprocal),
		.x1(x1)
	);
	assign mant_div = mant1_st1 * x1;
	wire mant_div_less_than_one;
	assign mant_div_less_than_one = (mant_div & (1 << ((3 * MANT_SIZE) - 2))) == 0;
	assign mant_out = (mant_div_less_than_one ? mant_div << 1 : mant_div);
	assign te_out = (mant_div_less_than_one ? te_diff_st1 - 1 : te_diff_st1);
	assign frac_truncated = 1'b0;
	always @(posedge clk)
		if (rst) begin
			te_diff_st1 <= 0;
			mant1_st1 <= 0;
		end
		else begin
			te_diff_st1 <= te_diff_st0;
			mant1_st1 <= mant1_st0;
		end
endmodule
module fast_reciprocal (
	fraction,
	one_over_fraction
);
	parameter SIZE = 4;
	input [SIZE - 1:0] fraction;
	output wire [(3 * SIZE) - 5:0] one_over_fraction;
	wire [SIZE - 1:0] i_data;
	wire [(3 * SIZE) - 4:0] o_data;
	assign i_data = fraction >> 1;
	reciprocal_approx #(.N(SIZE)) reciprocal_approx_inst(
		.i_data(i_data),
		.o_data(o_data)
	);
	assign one_over_fraction = o_data >> 1;
endmodule
module lut (
	addr,
	out
);
	parameter LUT_WIDTH_IN = 8;
	parameter LUT_WIDTH_OUT = 9;
	input [LUT_WIDTH_IN - 1:0] addr;
	output wire [LUT_WIDTH_OUT - 1:0] out;
	reg [LUT_WIDTH_OUT - 1:0] dout;
	reg [LUT_WIDTH_OUT - 1:0] mant_recip_rom [(2 ** LUT_WIDTH_IN) - 1:0];
	always @(*)
		case (addr)
			8'd0: dout = 9'h000;
			8'd1: dout = 9'h1fe;
			8'd2: dout = 9'h1fc;
			8'd3: dout = 9'h1fa;
			8'd4: dout = 9'h1f8;
			8'd5: dout = 9'h1f6;
			8'd6: dout = 9'h1f4;
			8'd7: dout = 9'h1f2;
			8'd8: dout = 9'h1f0;
			8'd9: dout = 9'h1ef;
			8'd10: dout = 9'h1ed;
			8'd11: dout = 9'h1eb;
			8'd12: dout = 9'h1e9;
			8'd13: dout = 9'h1e7;
			8'd14: dout = 9'h1e5;
			8'd15: dout = 9'h1e4;
			8'd16: dout = 9'h1e2;
			8'd17: dout = 9'h1e0;
			8'd18: dout = 9'h1de;
			8'd19: dout = 9'h1dd;
			8'd20: dout = 9'h1db;
			8'd21: dout = 9'h1d9;
			8'd22: dout = 9'h1d7;
			8'd23: dout = 9'h1d6;
			8'd24: dout = 9'h1d4;
			8'd25: dout = 9'h1d2;
			8'd26: dout = 9'h1d1;
			8'd27: dout = 9'h1cf;
			8'd28: dout = 9'h1ce;
			8'd29: dout = 9'h1cc;
			8'd30: dout = 9'h1ca;
			8'd31: dout = 9'h1c9;
			8'd32: dout = 9'h1c7;
			8'd33: dout = 9'h1c6;
			8'd34: dout = 9'h1c4;
			8'd35: dout = 9'h1c2;
			8'd36: dout = 9'h1c1;
			8'd37: dout = 9'h1bf;
			8'd38: dout = 9'h1be;
			8'd39: dout = 9'h1bc;
			8'd40: dout = 9'h1bb;
			8'd41: dout = 9'h1b9;
			8'd42: dout = 9'h1b8;
			8'd43: dout = 9'h1b6;
			8'd44: dout = 9'h1b5;
			8'd45: dout = 9'h1b3;
			8'd46: dout = 9'h1b2;
			8'd47: dout = 9'h1b1;
			8'd48: dout = 9'h1af;
			8'd49: dout = 9'h1ae;
			8'd50: dout = 9'h1ac;
			8'd51: dout = 9'h1ab;
			8'd52: dout = 9'h1aa;
			8'd53: dout = 9'h1a8;
			8'd54: dout = 9'h1a7;
			8'd55: dout = 9'h1a5;
			8'd56: dout = 9'h1a4;
			8'd57: dout = 9'h1a3;
			8'd58: dout = 9'h1a1;
			8'd59: dout = 9'h1a0;
			8'd60: dout = 9'h19f;
			8'd61: dout = 9'h19d;
			8'd62: dout = 9'h19c;
			8'd63: dout = 9'h19b;
			8'd64: dout = 9'h19a;
			8'd65: dout = 9'h198;
			8'd66: dout = 9'h197;
			8'd67: dout = 9'h196;
			8'd68: dout = 9'h195;
			8'd69: dout = 9'h193;
			8'd70: dout = 9'h192;
			8'd71: dout = 9'h191;
			8'd72: dout = 9'h190;
			8'd73: dout = 9'h18e;
			8'd74: dout = 9'h18d;
			8'd75: dout = 9'h18c;
			8'd76: dout = 9'h18b;
			8'd77: dout = 9'h18a;
			8'd78: dout = 9'h188;
			8'd79: dout = 9'h187;
			8'd80: dout = 9'h186;
			8'd81: dout = 9'h185;
			8'd82: dout = 9'h184;
			8'd83: dout = 9'h183;
			8'd84: dout = 9'h182;
			8'd85: dout = 9'h180;
			8'd86: dout = 9'h17f;
			8'd87: dout = 9'h17e;
			8'd88: dout = 9'h17d;
			8'd89: dout = 9'h17c;
			8'd90: dout = 9'h17b;
			8'd91: dout = 9'h17a;
			8'd92: dout = 9'h179;
			8'd93: dout = 9'h178;
			8'd94: dout = 9'h176;
			8'd95: dout = 9'h175;
			8'd96: dout = 9'h174;
			8'd97: dout = 9'h173;
			8'd98: dout = 9'h172;
			8'd99: dout = 9'h171;
			8'd100: dout = 9'h170;
			8'd101: dout = 9'h16f;
			8'd102: dout = 9'h16e;
			8'd103: dout = 9'h16d;
			8'd104: dout = 9'h16c;
			8'd105: dout = 9'h16b;
			8'd106: dout = 9'h16a;
			8'd107: dout = 9'h169;
			8'd108: dout = 9'h168;
			8'd109: dout = 9'h167;
			8'd110: dout = 9'h166;
			8'd111: dout = 9'h165;
			8'd112: dout = 9'h164;
			8'd113: dout = 9'h163;
			8'd114: dout = 9'h162;
			8'd115: dout = 9'h161;
			8'd116: dout = 9'h160;
			8'd117: dout = 9'h15f;
			8'd118: dout = 9'h15e;
			8'd119: dout = 9'h15e;
			8'd120: dout = 9'h15d;
			8'd121: dout = 9'h15c;
			8'd122: dout = 9'h15b;
			8'd123: dout = 9'h15a;
			8'd124: dout = 9'h159;
			8'd125: dout = 9'h158;
			8'd126: dout = 9'h157;
			8'd127: dout = 9'h156;
			8'd128: dout = 9'h155;
			8'd129: dout = 9'h154;
			8'd130: dout = 9'h154;
			8'd131: dout = 9'h153;
			8'd132: dout = 9'h152;
			8'd133: dout = 9'h151;
			8'd134: dout = 9'h150;
			8'd135: dout = 9'h14f;
			8'd136: dout = 9'h14e;
			8'd137: dout = 9'h14e;
			8'd138: dout = 9'h14d;
			8'd139: dout = 9'h14c;
			8'd140: dout = 9'h14b;
			8'd141: dout = 9'h14a;
			8'd142: dout = 9'h149;
			8'd143: dout = 9'h149;
			8'd144: dout = 9'h148;
			8'd145: dout = 9'h147;
			8'd146: dout = 9'h146;
			8'd147: dout = 9'h145;
			8'd148: dout = 9'h144;
			8'd149: dout = 9'h144;
			8'd150: dout = 9'h143;
			8'd151: dout = 9'h142;
			8'd152: dout = 9'h141;
			8'd153: dout = 9'h140;
			8'd154: dout = 9'h140;
			8'd155: dout = 9'h13f;
			8'd156: dout = 9'h13e;
			8'd157: dout = 9'h13d;
			8'd158: dout = 9'h13d;
			8'd159: dout = 9'h13c;
			8'd160: dout = 9'h13b;
			8'd161: dout = 9'h13a;
			8'd162: dout = 9'h13a;
			8'd163: dout = 9'h139;
			8'd164: dout = 9'h138;
			8'd165: dout = 9'h137;
			8'd166: dout = 9'h137;
			8'd167: dout = 9'h136;
			8'd168: dout = 9'h135;
			8'd169: dout = 9'h134;
			8'd170: dout = 9'h134;
			8'd171: dout = 9'h133;
			8'd172: dout = 9'h132;
			8'd173: dout = 9'h132;
			8'd174: dout = 9'h131;
			8'd175: dout = 9'h130;
			8'd176: dout = 9'h12f;
			8'd177: dout = 9'h12f;
			8'd178: dout = 9'h12e;
			8'd179: dout = 9'h12d;
			8'd180: dout = 9'h12d;
			8'd181: dout = 9'h12c;
			8'd182: dout = 9'h12b;
			8'd183: dout = 9'h12b;
			8'd184: dout = 9'h12a;
			8'd185: dout = 9'h129;
			8'd186: dout = 9'h129;
			8'd187: dout = 9'h128;
			8'd188: dout = 9'h127;
			8'd189: dout = 9'h127;
			8'd190: dout = 9'h126;
			8'd191: dout = 9'h125;
			8'd192: dout = 9'h125;
			8'd193: dout = 9'h124;
			8'd194: dout = 9'h123;
			8'd195: dout = 9'h123;
			8'd196: dout = 9'h122;
			8'd197: dout = 9'h121;
			8'd198: dout = 9'h121;
			8'd199: dout = 9'h120;
			8'd200: dout = 9'h11f;
			8'd201: dout = 9'h11f;
			8'd202: dout = 9'h11e;
			8'd203: dout = 9'h11e;
			8'd204: dout = 9'h11d;
			8'd205: dout = 9'h11c;
			8'd206: dout = 9'h11c;
			8'd207: dout = 9'h11b;
			8'd208: dout = 9'h11a;
			8'd209: dout = 9'h11a;
			8'd210: dout = 9'h119;
			8'd211: dout = 9'h119;
			8'd212: dout = 9'h118;
			8'd213: dout = 9'h117;
			8'd214: dout = 9'h117;
			8'd215: dout = 9'h116;
			8'd216: dout = 9'h116;
			8'd217: dout = 9'h115;
			8'd218: dout = 9'h115;
			8'd219: dout = 9'h114;
			8'd220: dout = 9'h113;
			8'd221: dout = 9'h113;
			8'd222: dout = 9'h112;
			8'd223: dout = 9'h112;
			8'd224: dout = 9'h111;
			8'd225: dout = 9'h110;
			8'd226: dout = 9'h110;
			8'd227: dout = 9'h10f;
			8'd228: dout = 9'h10f;
			8'd229: dout = 9'h10e;
			8'd230: dout = 9'h10e;
			8'd231: dout = 9'h10d;
			8'd232: dout = 9'h10d;
			8'd233: dout = 9'h10c;
			8'd234: dout = 9'h10b;
			8'd235: dout = 9'h10b;
			8'd236: dout = 9'h10a;
			8'd237: dout = 9'h10a;
			8'd238: dout = 9'h109;
			8'd239: dout = 9'h109;
			8'd240: dout = 9'h108;
			8'd241: dout = 9'h108;
			8'd242: dout = 9'h107;
			8'd243: dout = 9'h107;
			8'd244: dout = 9'h106;
			8'd245: dout = 9'h106;
			8'd246: dout = 9'h105;
			8'd247: dout = 9'h105;
			8'd248: dout = 9'h104;
			8'd249: dout = 9'h104;
			8'd250: dout = 9'h103;
			8'd251: dout = 9'h103;
			8'd252: dout = 9'h102;
			8'd253: dout = 9'h102;
			8'd254: dout = 9'h101;
			8'd255: dout = 9'h101;
			default: dout = 'h0;
		endcase
	assign out = dout;
endmodule
module reciprocal_approx (
	i_data,
	o_data
);
	parameter N = 10;
	input [N - 1:0] i_data;
	output wire [(3 * N) - 4:0] o_data;
	reg [N - 1:0] a;
	reg [N - 1:0] b;
	reg [(2 * N) - 2:0] c;
	reg [(2 * N) - 2:0] d;
	reg [(3 * N) - 2:0] e;
	reg [(3 * N) - 4:0] out;
	wire [N:1] sv2v_tmp_A712E;
	assign sv2v_tmp_A712E = i_data;
	always @(*) a = sv2v_tmp_A712E;
	localparam fx_1_466___N16 = 14'd12009;
	wire [N - 1:0] fx_1_466 = fx_1_466___N16;
	localparam fx_1_0012___N16 = 27'd67189395;
	wire [(2 * N) - 2:0] fx_1_0012 = fx_1_0012___N16;
	wire [N:1] sv2v_tmp_9C21A;
	assign sv2v_tmp_9C21A = fx_1_466 - a;
	always @(*) b = sv2v_tmp_9C21A;
	wire [(((2 * N) - 2) >= 0 ? (2 * N) - 1 : 3 - (2 * N)):1] sv2v_tmp_BCC2E;
	assign sv2v_tmp_BCC2E = (($signed(a) * $signed(b)) << 1) >> 1;
	always @(*) c = sv2v_tmp_BCC2E;
	wire [(((2 * N) - 2) >= 0 ? (2 * N) - 1 : 3 - (2 * N)):1] sv2v_tmp_AB638;
	assign sv2v_tmp_AB638 = fx_1_0012 - c;
	always @(*) d = sv2v_tmp_AB638;
	wire [(((3 * N) - 2) >= 0 ? (3 * N) - 1 : 3 - (3 * N)):1] sv2v_tmp_AD1C3;
	assign sv2v_tmp_AD1C3 = $signed(d) * $signed(b);
	always @(*) e = sv2v_tmp_AD1C3;
	wire [(((3 * N) - 4) >= 0 ? (3 * N) - 3 : 5 - (3 * N)):1] sv2v_tmp_F7E99;
	assign sv2v_tmp_F7E99 = e;
	always @(*) out = sv2v_tmp_F7E99;
	assign o_data = out;
endmodule
module newton_raphson (
	clk,
	rst,
	num,
	x0,
	x1
);
	parameter MS = 10;
	input clk;
	input rst;
	input [MS - 1:0] num;
	input [(3 * MS) - 5:0] x0;
	output wire [(2 * MS) - 1:0] x1;
	wire [(2 * MS) - 1:0] num_times_x0_st0;
	reg [(2 * MS) - 1:0] num_times_x0_st1;
	wire [(2 * MS) - 1:0] x0_on_2n_bits_st0;
	reg [(2 * MS) - 1:0] x0_on_2n_bits_st1;
	always @(posedge clk)
		if (rst) begin
			num_times_x0_st1 <= 0;
			x0_on_2n_bits_st1 <= 0;
		end
		else begin
			num_times_x0_st1 <= num_times_x0_st0;
			x0_on_2n_bits_st1 <= x0_on_2n_bits_st0;
		end
	wire [(4 * MS) - 4:0] _num_times_x0;
	assign _num_times_x0 = (num * x0) >> ((2 * MS) - 4);
	assign num_times_x0_st0 = _num_times_x0;
	localparam fx_2___N16 = 28'd134217728;
	wire [(2 * MS) - 1:0] fx_2 = fx_2___N16;
	wire [(2 * MS) - 1:0] two_minus_num_x0;
	assign two_minus_num_x0 = fx_2 - num_times_x0_st1;
	assign x0_on_2n_bits_st0 = x0 >> (MS - 4);
	wire [(4 * MS) - 1:0] _x1;
	assign _x1 = x0_on_2n_bits_st1 * two_minus_num_x0;
	assign x1 = _x1 >> ((2 * MS) - 2);
endmodule
module pack_fields (
	frac_full,
	total_exp,
	frac_truncated,
	k,
	next_exp,
	frac,
	round_bit,
	sticky_bit,
	k_is_oob,
	non_zero_frac_field_size
);
	parameter N = 4;
	parameter ES = 0;
	localparam MANT_SIZE = N - 2;
	localparam MS = MANT_SIZE;
	localparam RECIPROCATE_MANT_SIZE = 2 * MANT_SIZE;
	localparam RMS = RECIPROCATE_MANT_SIZE;
	localparam MANT_DIV_RESULT_SIZE = MS + RMS;
	localparam FRAC_FULL_SIZE = MANT_DIV_RESULT_SIZE - 2;
	input [FRAC_FULL_SIZE - 1:0] frac_full;
	localparam S = $clog2(N);
	localparam TE_SIZE = (ES + 1) + (S + 1);
	input [TE_SIZE - 1:0] total_exp;
	input frac_truncated;
	localparam K_SIZE = S + 2;
	output wire [K_SIZE - 1:0] k;
	output wire [ES - 1:0] next_exp;
	output wire [MANT_SIZE - 1:0] frac;
	output wire round_bit;
	output wire sticky_bit;
	output wire k_is_oob;
	output wire non_zero_frac_field_size;
	wire [K_SIZE - 1:0] k_unpacked;
	wire [ES - 1:0] exp_unpacked;
	unpack_exponent #(
		.N(N),
		.ES(ES)
	) unpack_exponent_inst(
		.total_exp(total_exp),
		.k(k_unpacked),
		.exp(exp_unpacked)
	);
	wire [K_SIZE - 1:0] regime_k;
	assign regime_k = (($signed(k_unpacked) <= (N - 2)) && ($signed(k_unpacked) >= (2 - N)) ? $signed(k_unpacked) : ($signed(k_unpacked) >= 0 ? N - 2 : 2 - N));
	assign k_is_oob = k_unpacked != regime_k;
	localparam REG_LEN_SIZE = S + 1;
	wire [REG_LEN_SIZE - 1:0] reg_len;
	assign reg_len = ($signed(regime_k) >= 0 ? regime_k + 2 : 1 - $signed(regime_k));
	localparam MANT_LEN_SIZE = S + 1;
	wire [MANT_LEN_SIZE - 1:0] frac_len;
	assign frac_len = ((N - 1) - ES) - reg_len;
	wire [ES:0] es_actual_len;
	function [N - 1:0] min;
		input [N - 1:0] a;
		input [N - 1:0] b;
		min = ($signed(a) <= $signed(b) ? a : b);
	endfunction
	assign es_actual_len = min(ES, (N - 1) - reg_len);
	wire [ES - 1:0] exp1;
	function [N - 1:0] max;
		input [N - 1:0] a;
		input [N - 1:0] b;
		max = (a >= b ? a : b);
	endfunction
	assign exp1 = exp_unpacked >> max(0, ES - es_actual_len);
	wire [S + 1:0] frac_len_diff;
	assign frac_len_diff = FRAC_FULL_SIZE - $signed(frac_len);
	compute_rouding #(
		.N(N),
		.ES(ES)
	) compute_rouding_inst(
		.frac_len(frac_len),
		.frac_full(frac_full),
		.frac_len_diff(frac_len_diff),
		.k(regime_k),
		.exp(exp_unpacked),
		.frac_truncated(frac_truncated),
		.round_bit(round_bit),
		.sticky_bit(sticky_bit)
	);
	assign k = regime_k;
	wire [ES - 1:0] exp2;
	assign exp2 = exp1 << (ES - es_actual_len);
	assign frac = frac_full >> frac_len_diff;
	assign non_zero_frac_field_size = $signed(frac_len) >= 0;
	assign next_exp = exp2;
endmodule
module unpack_exponent (
	total_exp,
	k,
	exp
);
	parameter N = 4;
	parameter ES = 1;
	localparam S = $clog2(N);
	localparam TE_SIZE = (ES + 1) + (S + 1);
	input [TE_SIZE - 1:0] total_exp;
	localparam K_SIZE = S + 2;
	output wire [K_SIZE - 1:0] k;
	output wire [ES - 1:0] exp;
	assign k = total_exp >> ES;
	assign exp = total_exp - ((1 << ES) * k);
endmodule
module compute_rouding (
	frac_len,
	frac_full,
	frac_len_diff,
	k,
	exp,
	frac_truncated,
	round_bit,
	sticky_bit
);
	parameter N = 5;
	parameter ES = 0;
	localparam S = $clog2(N);
	localparam MANT_LEN_SIZE = S + 1;
	input [MANT_LEN_SIZE - 1:0] frac_len;
	localparam MANT_SIZE = N - 2;
	localparam MS = MANT_SIZE;
	localparam RECIPROCATE_MANT_SIZE = 2 * MANT_SIZE;
	localparam RMS = RECIPROCATE_MANT_SIZE;
	localparam MANT_DIV_RESULT_SIZE = MS + RMS;
	localparam FRAC_FULL_SIZE = MANT_DIV_RESULT_SIZE - 2;
	input [FRAC_FULL_SIZE - 1:0] frac_full;
	input [S + 1:0] frac_len_diff;
	localparam K_SIZE = S + 2;
	input [K_SIZE - 1:0] k;
	input [ES - 1:0] exp;
	input frac_truncated;
	output wire round_bit;
	output wire sticky_bit;
	wire [(3 * MANT_SIZE) + 1:0] _tmp0;
	wire [(3 * MANT_SIZE) + 1:0] _tmp1;
	wire [(3 * MANT_SIZE) + 1:0] _tmp2;
	wire [(3 * MANT_SIZE) + 1:0] _tmp3;
	assign _tmp0 = 1 << (frac_len_diff - 1);
	assign _tmp1 = frac_full & _tmp0;
	assign round_bit = ($signed(frac_len) >= 0 ? _tmp1 != 0 : ($signed(k) == ((N - 2) - ES) ? (exp > 0) && ($unsigned(frac_full) > 0) : ($signed(k) == (2 - N) ? exp > 0 : 1'b0)));
	assign _tmp2 = (1 << (frac_len_diff - 1)) - 1;
	assign _tmp3 = frac_full & _tmp2;
	assign sticky_bit = ($signed(frac_len) >= 0 ? (_tmp3 != 0) || frac_truncated : 1'b0);
endmodule
module posit_unpack (
	bits,
	sign,
	reg_s,
	reg_len,
	k,
	exp,
	mant
);
	parameter N = 5;
	parameter ES = 0;
	input [N - 1:0] bits;
	output wire sign;
	output wire reg_s;
	localparam S = $clog2(N);
	localparam REG_LEN_SIZE = S + 1;
	output wire [REG_LEN_SIZE - 1:0] reg_len;
	localparam K_SIZE = S + 2;
	output wire [K_SIZE - 1:0] k;
	output wire [ES - 1:0] exp;
	localparam MANT_SIZE = N - 2;
	output wire [MANT_SIZE - 1:0] mant;
	assign sign = bits[N - 1];
	wire [N - 1:0] u_bits;
	function [N - 1:0] c2;
		input [N - 1:0] a;
		c2 = ~a + 1'b1;
	endfunction
	assign u_bits = (sign == 0 ? bits : c2(bits));
	wire [S - 1:0] leading_set;
	wire [S - 1:0] leading_set_2;
	assign reg_s = u_bits[N - 2];
	wire is_special_case;
	assign is_special_case = bits == {1'b1, {N - 2 {1'b0}}, 1'b1};
	assign leading_set_2 = (is_special_case ? N - 1 : leading_set);
	assign k = (reg_s == 1 ? leading_set_2 - 1 : c2(leading_set_2));
	assign reg_len = (reg_s == 1 ? k + 2 : c2(k) + 1);
	assign exp = (u_bits << (1 + reg_len)) >> (N - ES);
	wire [S:0] mant_len;
	assign mant_len = ((N - 1) - reg_len) - ES;
	localparam FRAC_SIZE = N - 1;
	wire [FRAC_SIZE - 1:0] frac;
	assign frac = (u_bits << (N - mant_len)) >> (N - mant_len);
	parameter MSB = 1 << (MANT_SIZE - 1);
	assign mant = MSB | (frac << ((MANT_SIZE - mant_len) - 1));
	wire [N - 1:0] bits_cls_in = (sign == 0 ? u_bits : ~u_bits);
	wire val = bits_cls_in[N - 2];
	wire [S - 1:0] leading_set_out_lzc;
	wire lzc_is_valid;
	lzc #(.NUM_BITS(N)) lzc_inst(
		.in((val == 1'b0 ? bits_cls_in : ~bits_cls_in) << 1),
		.out(leading_set_out_lzc),
		.vld(lzc_is_valid)
	);
	assign leading_set = (lzc_is_valid == 1'b1 ? leading_set_out_lzc : N - 1);
endmodule
module posit_decoder (
	bits,
	sign,
	te,
	mant
);
	parameter N = 4;
	parameter ES = 0;
	input [N - 1:0] bits;
	output wire sign;
	localparam S = $clog2(N);
	localparam TE_SIZE = (ES + 1) + (S + 1);
	output wire [TE_SIZE - 1:0] te;
	localparam MANT_SIZE = N - 2;
	output wire [MANT_SIZE - 1:0] mant;
	wire _reg_s;
	localparam REG_LEN_SIZE = S + 1;
	wire [REG_LEN_SIZE - 1:0] _reg_len;
	wire [ES - 1:0] exp;
	localparam K_SIZE = S + 2;
	wire [K_SIZE - 1:0] k;
	posit_unpack #(
		.N(N),
		.ES(ES)
	) posit_unpack_inst(
		.bits(bits),
		.sign(sign),
		.reg_s(_reg_s),
		.reg_len(_reg_len),
		.k(k),
		.exp(exp),
		.mant(mant)
	);
	total_exponent #(
		.N(N),
		.ES(ES)
	) total_exponent_inst(
		.k(k),
		.exp(exp),
		.total_exp(te)
	);
endmodule
module posit_encoder (
	sign,
	k,
	exp,
	frac,
	posit
);
	parameter N = 4;
	parameter ES = 1;
	input sign;
	localparam S = $clog2(N);
	localparam K_SIZE = S + 2;
	input [K_SIZE - 1:0] k;
	input [ES - 1:0] exp;
	localparam MANT_SIZE = N - 2;
	input [MANT_SIZE - 1:0] frac;
	output wire [N - 1:0] posit;
	localparam REG_LEN_SIZE = S + 1;
	wire [REG_LEN_SIZE - 1:0] reg_len;
	assign reg_len = ($signed(k) >= 0 ? k + 2 : 1 - $signed(k));
	wire [N - 1:0] bits_assembled;
	wire [N:0] regime_bits;
	function is_negative;
		input [S:0] k;
		is_negative = k[S];
	endfunction
	function [N - 1:0] c2;
		input [N - 1:0] a;
		c2 = ~a + 1'b1;
	endfunction
	function [N - 1:0] shl;
		input [N - 1:0] bits;
		input [N - 1:0] rhs;
		shl = (rhs[N - 1] == 0 ? bits << rhs : bits >> c2(rhs));
	endfunction
	assign regime_bits = (is_negative(k) ? 1 : (shl(1, k + 1) - 1) << 1);
	assign bits_assembled = ((shl(sign, N - 1) + shl(regime_bits, (N - 1) - reg_len)) + shl(exp, ((N - 1) - reg_len) - ES)) + frac;
	assign posit = (sign == 0 ? bits_assembled : c2(bits_assembled & ~(1 << (N - 1))));
endmodule
module lzc (
	in,
	out,
	vld
);
	parameter NUM_BITS = 16;
	input [NUM_BITS - 1:0] in;
	output wire [$clog2(NUM_BITS) - 1:0] out;
	output wire vld;
	lzc_internal #(.NUM_BITS(NUM_BITS)) l1(
		.in(in),
		.out(out),
		.vld(vld)
	);
endmodule
module lzc_internal (
	in,
	out,
	vld
);
	parameter NUM_BITS = 8;
	input [NUM_BITS - 1:0] in;
	output wire [$clog2(NUM_BITS) - 1:0] out;
	output wire vld;
	localparam S = $clog2(NUM_BITS);
	generate
		if (NUM_BITS == 2) begin : gen_blk1
			assign vld = |in;
			assign out = ~in[1] & in[0];
		end
		else if (NUM_BITS & (NUM_BITS - 1)) begin : gen_blk2
			lzc_internal #(.NUM_BITS(1 << S)) lzc_internal(
				.in({in, {(1 << S) - NUM_BITS {1'b0}}}),
				.out(out),
				.vld(vld)
			);
		end
		else begin : gen_blk3
			wire [S - 2:0] out_l;
			wire [S - 2:0] out_h;
			wire out_vl;
			wire out_vh;
			lzc_internal #(.NUM_BITS(NUM_BITS >> 1)) l(
				.in(in[(NUM_BITS >> 1) - 1:0]),
				.out(out_l),
				.vld(out_vl)
			);
			lzc_internal #(.NUM_BITS(NUM_BITS >> 1)) h(
				.in(in[NUM_BITS - 1:NUM_BITS >> 1]),
				.out(out_h),
				.vld(out_vh)
			);
			assign vld = out_vl | out_vh;
			assign out = (out_vh ? {1'b0, out_h} : {out_vl, out_l});
		end
	endgenerate
endmodule
module round_posit (
	posit,
	round_bit,
	sticky_bit,
	k_is_oob,
	non_zero_frac_field_size,
	posit_rounded
);
	parameter N = 10;
	input [N - 1:0] posit;
	input round_bit;
	input sticky_bit;
	input k_is_oob;
	input non_zero_frac_field_size;
	output wire [N - 1:0] posit_rounded;
	wire guard_bit;
	assign guard_bit = posit[0];
	assign posit_rounded = ((!k_is_oob && round_bit) && (!non_zero_frac_field_size || (guard_bit || sticky_bit)) ? posit + 1'b1 : posit);
endmodule
module sign_decisor (
	clk,
	rst,
	sign1,
	sign2,
	op,
	sign
);
	input clk;
	input rst;
	input sign1;
	input sign2;
	localparam OP_SIZE = 3;
	input [2:0] op;
	output wire sign;
	reg sign1_st1;
	reg sign2_st1;
	localparam ADD = 3'd0;
	localparam SUB = 3'd1;
	assign sign = ((op == ADD) || (op == SUB) ? sign1_st1 : sign1_st1 ^ sign2_st1);
	always @(posedge clk)
		if (rst) begin
			sign1_st1 <= 0;
			sign2_st1 <= 0;
		end
		else begin
			sign1_st1 <= sign1;
			sign2_st1 <= sign2;
		end
endmodule
module set_sign (
	posit_in,
	sign,
	posit_out
);
	parameter N = 9;
	input [N - 1:0] posit_in;
	input sign;
	output wire [N - 1:0] posit_out;
	function [N - 1:0] c2;
		input [N - 1:0] a;
		c2 = ~a + 1'b1;
	endfunction
	assign posit_out = (sign == 0 ? posit_in : c2(posit_in));
endmodule
module ppu_control_unit (
	clk,
	rst,
	valid_i,
	op,
	valid_o,
	stall_o
);
	input clk;
	input rst;
	input valid_i;
	localparam OP_SIZE = 3;
	input [2:0] op;
	output wire valid_o;
	output reg stall_o;
	reg valid;
	localparam INIT = 0;
	reg [0:0] state_reg = INIT;
	localparam ANY_OP = 1;
	wire [2:0] __op = op;
	always @(posedge clk)
		if (rst)
			state_reg <= INIT;
		else
			case (state_reg)
				INIT:
					if (valid_i)
						state_reg <= ANY_OP;
					else
						state_reg <= INIT;
				ANY_OP:
					if (valid_i)
						state_reg <= ANY_OP;
					else
						state_reg <= INIT;
				default: state_reg <= state_reg;
			endcase
	always @(*)
		case (state_reg)
			INIT: begin
				stall_o = 0;
				valid = 0;
			end
			ANY_OP: begin
				stall_o = 0;
				valid = 1;
			end
			default: begin
				stall_o = 0;
				valid = 0;
			end
		endcase
	reg valid_in_st0;
	reg valid_in_st1;
	reg valid_in_st2;
	always @(posedge clk)
		if (rst) begin
			valid_in_st0 <= 0;
			valid_in_st1 <= 0;
			valid_in_st2 <= 0;
		end
		else begin
			valid_in_st0 <= valid;
			valid_in_st1 <= valid_in_st0;
			valid_in_st2 <= valid_in_st1;
		end
	assign valid_o = valid_in_st1;
endmodule
module reg_banks (
	clk,
	rst,
	stall_i,
	delay_op,
	fir1_in,
	fir2_in,
	op_in,
	special_in,
	fir1_out,
	fir2_out,
	op_out,
	special_out
);
	input clk;
	input rst;
	input stall_i;
	input delay_op;
	localparam N = 16;
	localparam MANT_SIZE = 14;
	localparam ES = 2;
	localparam S = 4;
	localparam TE_SIZE = 8;
	localparam FIR_SIZE = 23;
	input [22:0] fir1_in;
	input [22:0] fir2_in;
	localparam OP_SIZE = 3;
	input [2:0] op_in;
	input [16:0] special_in;
	output reg [22:0] fir1_out;
	output reg [22:0] fir2_out;
	output reg [2:0] op_out;
	output reg [16:0] special_out;
	reg [2:0] op_intermediate;
	always @(posedge clk)
		if (rst) begin
			fir1_out <= 0;
			fir2_out <= 0;
			op_intermediate <= 0;
			op_out <= 0;
			special_out <= 0;
		end
		else begin
			fir1_out <= (stall_i ? fir1_out : fir1_in);
			fir2_out <= (stall_i ? fir2_out : fir2_in);
			op_intermediate <= (stall_i ? op_intermediate : op_in);
			op_out <= (delay_op ? (stall_i ? op_intermediate : op_in) : op_intermediate);
			special_out <= (stall_i ? special_out : special_in);
		end
endmodule
module pp_mul (
	clk,
	rst,
	a,
	b,
	product
);
	parameter M = 48;
	parameter N = 64;
	input clk;
	input rst;
	input [M - 1:0] a;
	input [N - 1:0] b;
	output reg [(M + N) - 1:0] product;
	reg [(M + N) - 1:0] product_st1;
	always @(posedge clk)
		if (rst)
			product <= 0;
		else
			product <= a * b;
endmodule
module float_decoder (
	bits,
	sign,
	exp,
	frac
);
	parameter FSIZE = 64;
	input [FSIZE - 1:0] bits;
	output wire sign;
	localparam FLOAT_EXP_SIZE_F32 = 8;
	localparam FLOAT_EXP_SIZE = FLOAT_EXP_SIZE_F32;
	output wire signed [7:0] exp;
	localparam FLOAT_MANT_SIZE_F32 = 23;
	localparam FLOAT_MANT_SIZE = FLOAT_MANT_SIZE_F32;
	output wire [22:0] frac;
	localparam exp_bias = 127;
	assign sign = (bits >> (FSIZE - 1)) != 0;
	wire [7:0] biased_exp;
	assign biased_exp = bits[FSIZE - 1-:9];
	assign exp = biased_exp - exp_bias;
	assign frac = bits[22:0];
endmodule
