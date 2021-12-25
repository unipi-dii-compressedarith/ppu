/*

# from within the `waveforms` folder
iverilog -DTEST_BENCH_MUL -DNO_ES_FIELD -DN=8 -DES=0  -o mul.out \
../src/mul.sv \
../src/mul_core.sv \
../src/posit_decode.sv \
../src/posit_encode.sv \
../src/cls.sv \
../src/highest_set.sv \
&& ./mul.out


iverilog -g2012 -DTEST_BENCH_MUL              -DN=16 -DES=1  -o mul.out \
../src/mul.sv \
../src/mul_core.sv \
../src/posit_decode.sv \
../src/posit_encode.sv \
../src/cls.sv \
../src/highest_set.sv \
&& ./mul.out

iverilog -DTEST_BENCH_MUL              -DN=32 -DES=2  -o mul.out \
../src/mul.sv \
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
../src/posit_decode.sv \
../src/posit_encode.sv \
../src/cls.sv \
../src/highest_set.sv > mul.v

sv2v -DN=16 -DES=1 \
../src/mul.sv \
../src/mul_core.sv \
../src/posit_decode.sv \
../src/posit_encode.sv \
../src/cls.sv \
../src/highest_set.sv > mul.v

yosys -p "synth_intel -family max10 -top mul -vqm mul.vqm" mul.sv mul_core.sv posit_decode.sv posit_encode.sv cls.sv highest_set.sv > mul_yosys_intel.out

*/


// `ifdef ALTERA_RESERVED_QIS
// `define NO_ES_FIELD
// `endif

module mul #(
// `ifdef ALTERA_RESERVED_QIS
//         parameter N = 16,
//         parameter ES = 1
// `else
        parameter N = 16,
        parameter ES = 1
// `endif
    )(
        input [N-1:0] p1, p2,
        output [N-1:0] pout
    );

    localparam S = $clog2(N);
    localparam DECODE_OUTPUT_SIZE = (
          1             // sign
        + 1             // reg_s
        + $clog2(N) + 1 // reg_len
        + $clog2(N) + 1 // k
`ifndef NO_ES_FIELD
        + ES            // exp
`endif
        + N             // mant
    );

    wire [1:0]                    p1_is_special, p2_is_special;
    wire [DECODE_OUTPUT_SIZE-1:0] p1_decode_out, p2_decode_out; 

    wire [(
          1             // sign
        + $clog2(N) + 1 // reg_len
        + $clog2(N) + 1 // k
`ifndef NO_ES_FIELD
        + ES            // exp
`endif
        + N             // mant
    ) - 1:0]        encode_in;
    wire            pout_is_zero, pout_is_inf;


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
        .encode_in          (encode_in)
    );

    posit_encode #(
        .N(N),
        .ES(ES)
    ) posit_encode_inst (
        .is_zero        (pout_is_zero),
        .is_inf         (pout_is_inf),
        .encode_in      (encode_in),
        .posit          (pout)
    );

endmodule





`ifdef TEST_BENCH_MUL
module tb_mul;


`ifdef N
    parameter N = `N;
`else
    parameter N = 8;
`endif

    parameter S = $clog2(N);

`ifdef ES
    parameter ES = `ES;
`else
    parameter ES = 0;
`endif  

    reg [N-1:0] p1, p2;
    wire [N-1:0] pout;

    reg [N-1:0] pout_expected;

    reg diff_pout;
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
    end

endmodule
`endif