/*

iverilog -g2012 -DN=16 -DES=1 -DTEST_BENCH_COMP_PACOGEN -o comparison_against_pacogen.out \
../src/utils.sv \
../src/common.sv \
../src/comparison_against_pacogen.sv \
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
../src/highest_set.sv \
../../PACoGen/common.v \
../../PACoGen/div/posit_div.v \
&& ./comparison_against_pacogen.out



*/



module comparison_against_pacogen #(
        parameter N = 16,
        parameter ES = 1
    )(
        input [N-1:0] p1,
        input [N-1:0] p2,
        input [OP_SIZE-1:0] op,
        output [N-1:0] pout_mine,
        output [N-1:0] pout_pacogen
    );

    not_ppu #(
        .N(N),
        .ES(ES)
    ) not_ppu_inst (
        .p1(p1),
        .p2(p2),
        .op(op),
        .pout(pout_mine)
    );

    posit_div #(
        .N(N),
        .es(ES)
    ) uut (
        .in1(p1), 
        .in2(p2), 
        .start(1), 
        .out(pout_pacogen), 
        .inf(), 
        .zero(), 
        .done()
    );


endmodule


`ifdef TEST_BENCH_COMP_PACOGEN
module tb_comparison_against_pacogen;


    reg [N-1:0]  p1, p2;
    reg [OP_SIZE-1:0] op;
    reg [100:0] op_ascii;
    wire [N-1:0] pout, pout_mine, pout_pacogen;

    
    reg [N-1:0] pout_expected;
    reg diff_pout_mine, diff_pout_pacogen, pout_off_by_1;
    reg [9:0] pout_diff_analog;
    reg [N:0] test_no;

    reg [100:0] count_errors;

    comparison_against_pacogen #(
        .N      (N),
        .ES     (ES)
    ) comparison_against_pacogen_inst (
        .p1     (p1),
        .p2     (p2),
        .op     (op),
        .pout_mine   (pout_mine),
        .pout_pacogen   (pout_pacogen)
    );

    
    always @(*) begin
        diff_pout_mine = pout_mine === pout_expected ? 0 : 1'bx;
        diff_pout_pacogen = pout_pacogen === pout_expected ? 0 : 1'bx;
        pout_off_by_1 = abs(pout_mine - pout_expected) == 0 ? 0 : abs(pout_mine - pout_expected) == 1 ? 1 : 'bx;

        pout_diff_analog = abs(pout_mine - pout_expected);
    end

    initial begin

        if (N == 16 && ES == 1)$dumpfile("tb_comparison_against_pacogen.vcd");
        
        $dumpvars(0, tb_comparison_against_pacogen);                        
            
        
        if (N == 16 && ES == 1) begin
            `include "../test_vectors/tv_posit_div_P16E1.sv"
        end

        
        #10;
        $finish;
    end



endmodule
`endif

