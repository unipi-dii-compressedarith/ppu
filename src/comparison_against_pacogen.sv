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
&& ./comparison_against_pacogen.out > comparison_against_pacogen.log

*/


module comparison_against_pacogen #(
        parameter N = 16,
        parameter ES = 1
    )(
        input [N-1:0] p1,
        input [N-1:0] p2,
        input [OP_SIZE-1:0] op,
        output [N-1:0] pout_not_ppu,
        output [N-1:0] pout_pacogen
    );


    not_ppu #(
        .N(N),
        .ES(ES)
    ) not_ppu_inst (
        .p1(p1),
        .p2(p2),
        .op(op),
        .pout(pout_not_ppu)
    );


    posit_div #(
        .N(N),
        .es(ES)
    ) uut (
        .in1(p1), 
        .in2(p2), 
        .start(1'b1), 
        .out(pout_pacogen), // pout_pacogen
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
    wire [N-1:0] pout_pacogen, pout_not_ppu;

    
    reg [N-1:0] pout_ground_truth;
    reg diff_pout_not_ppu, diff_pout_pacogen, not_ppu_off_by_1, pacogen_off_by_1;
    reg [N:0] test_no;

    reg [100:0] count_errors;

    comparison_against_pacogen #(
        .N      (N),
        .ES     (ES)
    ) comparison_against_pacogen_inst (
        .p1     (p1),
        .p2     (p2),
        .op     (op),
        .pout_not_ppu   (pout_not_ppu),
        .pout_pacogen   (pout_pacogen)
    );

    
    always @(*) begin
        diff_pout_not_ppu = pout_not_ppu === pout_ground_truth ? 0 : 1'bx;
        diff_pout_pacogen = pout_pacogen === pout_ground_truth ? 0 : 1'bx;
        not_ppu_off_by_1 = abs(pout_not_ppu - pout_ground_truth) == 0 ? 0 : abs(pout_not_ppu - pout_ground_truth) == 1 ? 1 : 'bx;
        pacogen_off_by_1 = abs(pout_pacogen - pout_ground_truth) == 0 ? 0 : abs(pout_pacogen - pout_ground_truth) == 1 ? 1 : 'bx;
    end

    initial begin

        if (N == 16 && ES == 1)$dumpfile("tb_comparison_against_pacogen.vcd");
        
        $dumpvars(0, tb_comparison_against_pacogen);                        
            
        
        if (N == 16 && ES == 1) begin
            `include "../test_vectors/tv_posit_pacogen_P16E1.sv"
        end

        
        #10;
        $finish;
    end

endmodule
`endif
