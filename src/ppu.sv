/*
sv2v             -DN=16 -DES=1  \
../src/utils.sv \
../src/common.sv \
../src/ppu.sv \
../src/not_ppu.sv \
../src/input_conditioning.sv \
../src/unpack_posit.sv \
../src/check_special.sv \
../src/handle_special.sv \
../src/total_exponent.sv \
../src/core_op.sv \
../src/core_add_sub.sv \
../src/core_add.sv \
../src/core_sub.sv \
../src/core_mul.sv \
../src/core_div.sv \
../src/fast_reciprocal.sv \
../src/reciprocal_approx.sv \
../src/newton_raphson.sv \
../src/shift_fields.sv \
../src/unpack_exponent.sv \
../src/compute_rounding.sv \
../src/posit_decode.sv \
../src/posit_encode.sv \
../src/cls.sv \
../src/round.sv \
../src/sign_decisor.sv \
../src/set_sign.sv \
../src/highest_set.sv > ./ppu.v && iverilog ppu.v

*/


module ppu #(
        parameter N = `N,
        parameter ES = `ES
    )(
        input clk,
        // input rst,
        input [N-1:0] p1,
        input [N-1:0] p2,
        input [OP_SIZE-1:0] op,
        output reg [N-1:0] pout
    );

    not_ppu #(
        .N(N),
        .ES(ES)
    ) not_ppu_inst (
        .p1(p1_reg),
        .p2(p2_reg),
        .op(op_reg),
        .pout(pout_reg)
    );

    reg [N-1:0] p1_reg, p2_reg, pout_reg;
    reg [OP_SIZE-1:0] op_reg;

    always @(posedge clk) begin
        p1_reg <= p1;
        p2_reg <= p2;
        op_reg <= op;
        pout <= pout_reg;    
    end

endmodule
