module float_to_posit #(
        parameter N = `N,
        parameter ES = `ES,
        parameter FSIZE = `F
    )(
        input [FSIZE-1:0] float_bits,
        output [N-1:0] posit  
    );

    wire sign;
    wire [TE_SIZE-1:0] exp;
    wire [FLOAT_MANT_SIZE-1:0] frac;

    wire [(1 + FLOAT_EXP_SIZE_F`F + FLOAT_MANT_SIZE_F`F)-1:0] fir_out;
    float_to_fir #(
        .FSIZE(FSIZE)
    ) float_to_fir_inst (
        .bits(float_bits),
        .fir(fir_out)
    );
    
    assign {sign, float_exp, frac} = fir_out;

    parameter FLOAT_EXP_SIZE = FLOAT_EXP_SIZE_F`F;
    parameter FLOAT_MANT_SIZE = FLOAT_MANT_SIZE_F`F;


    wire [FLOAT_EXP_SIZE-1:0] float_exp;
    assign exp = float_exp[TE_SIZE-1:0];

    wire [FRAC_FULL_SIZE-1:0] frac_full;
    assign frac_full = frac >> (FLOAT_MANT_SIZE - FRAC_FULL_SIZE);


    fir_to_posit #(
        .N(N),
        .ES(ES),
        .FIR_TOTAL_SIZE(1+TE_SIZE+FRAC_FULL_SIZE)
    ) fir_to_posit_inst (
        .ops_in({{sign, exp, frac_full}, 1'b0}),
        .posit(posit)
    );

endmodule



`ifdef TB_FLOAT_TO_POSIT
module tb_float_to_posit;

    parameter N = `N;
    parameter ES = `ES;
    parameter FSIZE = `F;
    parameter FLOAT_EXP_SIZE = FLOAT_EXP_SIZE_F`F;
    parameter FLOAT_MANT_SIZE = FLOAT_MANT_SIZE_F`F;


    reg [FSIZE-1:0] float_bits;
    
    wire [N-1:0] posit;
    reg [N-1:0] posit_expected;

    reg [200:0] ascii_x, ascii_exp, ascii_frac, posit_expected_ascii;
    

    float_to_posit #(
        .N(N),
        .ES(ES),
        .FSIZE(FSIZE)
    ) float_to_posit_inst (
        .float_bits(float_bits),
        .posit(posit)  
    );


    reg diff;
    always_comb @(*) begin
        diff = posit == posit_expected? 0 : 1'bX;
    end


    initial begin
        $dumpfile({"tb_float_F",`STRINGIFY(`F),"_to_posit_P",`STRINGIFY(`N),"E",`STRINGIFY(`ES),".vcd"});
        $dumpvars(0, tb_float_to_posit);                        

        // 8,0
        if (N == 8 && ES == 0 && FSIZE == 16) begin
            `include "../test_vectors/tv_float_to_posit_P8E0_F16.sv"
        end
        if (N == 8 && ES == 0 && FSIZE == 32) begin
            `include "../test_vectors/tv_float_to_posit_P8E0_F32.sv"
        end
        if (N == 8 && ES == 0 && FSIZE == 64) begin
            `include "../test_vectors/tv_float_to_posit_P8E0_F32.sv"
        end

        // 8,1
        if (N == 8 && ES == 1 && FSIZE == 16) begin
            `include "../test_vectors/tv_float_to_posit_P8E1_F16.sv"
        end
        if (N == 8 && ES == 1 && FSIZE == 32) begin
            `include "../test_vectors/tv_float_to_posit_P8E1_F32.sv"
        end
        if (N == 8 && ES == 1 && FSIZE == 64) begin
            `include "../test_vectors/tv_float_to_posit_P8E1_F32.sv"
        end

        // 16,0
        if (N == 16 && ES == 0 && FSIZE == 16) begin
            `include "../test_vectors/tv_float_to_posit_P16E0_F16.sv"
        end
        if (N == 16 && ES == 0 && FSIZE == 32) begin
            `include "../test_vectors/tv_float_to_posit_P16E0_F32.sv"
        end
        if (N == 16 && ES == 0 && FSIZE == 64) begin
            `include "../test_vectors/tv_float_to_posit_P16E0_F32.sv"
        end

        // 16,1
        if (N == 16 && ES == 1 && FSIZE == 16) begin
            `include "../test_vectors/tv_float_to_posit_P16E1_F16.sv"
        end
        if (N == 16 && ES == 1 && FSIZE == 32) begin
            `include "../test_vectors/tv_float_to_posit_P16E1_F32.sv"
        end
        if (N == 16 && ES == 1 && FSIZE == 64) begin
            `include "../test_vectors/tv_float_to_posit_P16E1_F32.sv"
        end

        // 16,2
        if (N == 16 && ES == 2 && FSIZE == 16) begin
            `include "../test_vectors/tv_float_to_posit_P16E2_F16.sv"
        end
        if (N == 16 && ES == 2 && FSIZE == 32) begin
            `include "../test_vectors/tv_float_to_posit_P16E2_F32.sv"
        end
        if (N == 16 && ES == 2 && FSIZE == 64) begin
            `include "../test_vectors/tv_float_to_posit_P16E2_F32.sv"
        end

        // 32,2
        if (N == 32 && ES == 2 && FSIZE == 16) begin
            `include "../test_vectors/tv_float_to_posit_P32E2_F16.sv"
        end
        if (N == 32 && ES == 2 && FSIZE == 32) begin
            `include "../test_vectors/tv_float_to_posit_P32E2_F32.sv"
        end
        if (N == 32 && ES == 2 && FSIZE == 64) begin
            `include "../test_vectors/tv_float_to_posit_P32E2_F32.sv"
        end
        
    end


endmodule
`endif
