module tb_posit_encoder;
    parameter N = `N;
    parameter ES = `ES;

    /* inputs */
    reg            is_zero;
    reg            is_nar;

    reg sign;
    reg [REG_LEN_BITS-1:0] reg_len;
    reg [K_BITS-1:0] k;
`ifndef NO_ES_FIELD
    reg [ES-1:0] exp;
`endif
    reg [MANT_SIZE-1:0] frac;

    /* output */
    wire [N-1:0]    posit;
    /*************************/

    reg [N-1:0]   posit_expected;
    reg err;

    reg [N:0] test_no;

    posit_encoder #(
        .N(N),
        .ES(ES)
    ) posit_encoder_inst (
        .is_zero_i(is_zero),
        .is_nar_i(is_nar),

        .sign(sign),
        .k(k),
`ifndef NO_ES_FIELD
        .exp(exp),
`endif
        .frac(frac),
        .posit(posit)
    );



    always_comb begin
        err = posit == posit_expected ? 0 : 1'bx;
    end

    initial begin
             if (N == 8  && ES == 0) $dumpfile("tb_posit_encoder_P8E0.vcd");
        else if (N == 5  && ES == 1) $dumpfile("tb_posit_encoder_P5E1.vcd");
        else if (N == 16 && ES == 1) $dumpfile("tb_posit_encoder_P16E1.vcd");
        else                         $dumpfile("tb_posit_encoder.vcd");

        $dumpvars(0, tb_posit_encoder);

    /*
        if (N == 8 && ES == 0) begin
            `include "../test_vectors/tv_posit_encoder_P8E0.sv"
        end

        if (N == 16 && ES == 1) begin
            `include "../test_vectors/tv_posit_encoder_P16E1.sv"
        end
    */

        #10;
        $finish;
    end

endmodule
