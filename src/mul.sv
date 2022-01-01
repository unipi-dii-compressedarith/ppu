/*

# from within the `waveforms` folder
iverilog -g2012 -DTEST_BENCH_MUL -DNO_ES_FIELD -DN=8 -DES=0  -o mul.out \
../src/round_mul.sv \
../src/mul.sv \
../src/utils.sv \
../src/mul_core.sv \
../src/posit_decode.sv \
../src/posit_encode.sv \
../src/cls.sv \
../src/highest_set.sv \
&& ./mul.out


iverilog -g2012 -DTEST_BENCH_MUL              -DN=16 -DES=1  -o mul.out \
../src/round_mul.sv \
../src/mul.sv \
../src/utils.sv \
../src/mul_core.sv \
../src/posit_decode.sv \
../src/posit_encode.sv \
../src/cls.sv \
../src/highest_set.sv \
&& ./mul.out

iverilog -g2012 -DTEST_BENCH_MUL              -DN=32 -DES=2  -o mul.out \
../src/round_mul.sv \
../src/mul.sv \
../src/utils.sv \
../src/mul_core.sv \
../src/posit_decode.sv \
../src/posit_encode.sv \
../src/cls.sv \
../src/highest_set.sv \
&& ./mul.out



# from within the `quartus` folder
sv2v -DN=16 -DES=1 \
../src/mul.sv \
../src/mul_core.sv \
../src/round_mul.sv \
../src/posit_decode.sv \
../src/posit_encode.sv \
../src/utils.sv \
../src/cls.sv \
../src/highest_set.sv > mul.v


yosys -p "synth_intel -family max10 -top mul -vqm mul.vqm" \
../src/mul.sv \
../src/utils.sv \
../src/mul_core.sv \
../src/posit_decode.sv \
../src/posit_encode.sv \
../src/cls.sv \
../src/highest_set.sv > mul_yosys_intel.out

*/


// `ifdef ALTERA_RESERVED_QIS
// `define NO_ES_FIELD
// `endif

module mul #(
// `ifdef ALTERA_RESERVED_QIS
//         parameter N = 16,
//         parameter ES = 1
// `else
        parameter N = `N,
        parameter ES = `ES
// `endif
    )(
        input [N-1:0] p1, p2,
        output [N-1:0] pout
    );

    wire [1:0]                    p1_is_special, p2_is_special;
    wire [DECODE_OUTPUT_SIZE-1:0] p1_decode_out, p2_decode_out; 

    wire [ENCODE_INPUT_SIZE-1:0]        encode_in;
    wire            pout_is_zero, pout_is_inf;

    wire [N-1:0] pout_not_rounded;

    posit_decode #(
        .N(N),
        .ES(ES)
    ) posit_decode_p1 (
        .bits           (p1),
        .decode_out     (p1_decode_out),
        .is_special     (p1_is_special)
    );

    posit_decode #(
        .N(N),
        .ES(ES)
    ) posit_decode_p2 (
        .bits           (p2),
        .decode_out     (p2_decode_out),
        .is_special     (p2_is_special)
    );

    mul_core #(
        .N                  (N),
        .ES                 (ES)
    ) mul_core_inst (  
        .p1_is_special      (p1_is_special),
        .p1_decode_out      (p1_decode_out),
        .p2_is_special      (p2_is_special),
        .p2_decode_out      (p2_decode_out),

        .pout_is_zero       (pout_is_zero),
        .pout_is_inf        (pout_is_inf),
        .encode_in          (encode_in),
        .rounding_signals   (rounding_signals)
    );

    posit_encode #(
        .N(N),
        .ES(ES)
    ) posit_encode_inst (
        .is_zero            (pout_is_zero),
        .is_inf             (pout_is_inf),
        .encode_in          (encode_in),
        .posit              (pout_not_rounded)
    );


    wire [(3)-1:0] rounding_signals;
    wire k_is_oob, bit_n_plus_one, bits_more;
    assign {k_is_oob, bit_n_plus_one, bits_more} = rounding_signals;

    round_mul #(
        .N(N)
    ) round_mul_inst (
        .posit_in           (pout_not_rounded),
        .rounding_signals   (rounding_signals),
        .posit_rounded_out  (pout)
    );

endmodule





`ifdef TEST_BENCH_MUL
module tb_mul;

    function [N-1:0] c2(input [N-1:0] a);
        c2 = ~a + 1'b1;
    endfunction
    function [N-1:0] abs(input [N-1:0] in);
        abs = in[N-1] == 0 ? in : c2(in);
    endfunction

`ifdef N
    parameter N = `N;
`else
    parameter N = 8;
`endif


`ifdef ES
    parameter ES = `ES;
`else
    parameter ES = 0;
`endif  

    reg [N-1:0] p1, p2;
    wire [N-1:0] pout;

    reg [N-1:0] pout_expected;

    reg diff_pout, pout_off_by_1;
    reg [N:0] test_no;

    mul #(
        .N      (N),
        .ES     (ES)
    ) mul_inst (
        .p1     (p1),
        .p2     (p2),
        .pout   (pout)
    );

    
    always @(*) begin
        diff_pout = pout === pout_expected ? 0 : 1'bx;
        pout_off_by_1 = abs(pout - pout_expected) == 0 ? 0 : abs(pout - pout_expected) == 1 ? 1 : 'bx;
    end

    initial begin
        
             if (N == 8 && ES == 0) $dumpfile("tb_mul_P8E0.vcd");
        else if (N == 5 && ES == 1) $dumpfile("tb_mul_P5E1.vcd");
        else if (N == 16 && ES == 1)$dumpfile("tb_mul_P16E1.vcd");
        else if (N == 32 && ES == 2)$dumpfile("tb_mul_P32E2.vcd");
        else                        $dumpfile("tb_mul.vcd");

        $dumpvars(0, tb_mul);                        
            
        if (N == 8 && ES == 0) begin
            `include "../test_vectors/tv_posit_mul_P8E0.sv"
        end

        if (N == 16 && ES == 1) begin
            `include "../test_vectors/tv_posit_mul_P16E1.sv"
        end

        if (N == 32 && ES == 2) begin
            `include "../test_vectors/tv_posit_mul_P32E2.sv"
        end


        #10;
        $finish;
    end

endmodule
`endif