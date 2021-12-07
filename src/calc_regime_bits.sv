/*
iverilog -DTEST_BENCH_CALC_REGIME_BITS calc_regime_bits.sv && ./a.out
*/
module calc_regime_bits #(
        parameter N = 8,
        parameter S = $clog2(N)
    )(
        input              reg_s,
        input [S-1:0]      reg_len,
        output [N-1:0] regime_bits
    );

    wire [N-1:0] mask = {N{1'b1}} >> (N - reg_len);
    assign regime_bits = reg_s == 0 ? 1 : (~0 ^ 1) & mask;
endmodule

`ifdef TEST_BENCH_CALC_REGIME_BITS
module tb_calc_regime_bits;

    parameter N = 8;
    parameter S = $clog2(N);
    reg reg_s;
    reg [S-1:0] reg_len;
    wire [N-1:0] regime_bits;


    calc_regime_bits #(
        .N(N),
        .S(S)
    ) calc_regime_bits_inst (
        .reg_s(reg_s),
        .reg_len(reg_len),
        .regime_bits(regime_bits)
    );


    initial begin     
        $dumpfile("tb_calc_regime_bits.vcd");
	    $dumpvars(0, tb_calc_regime_bits);                        

                reg_s = 1;
                reg_len = 4;
        
        #10;    reg_s = 0;
                reg_len =3;
        
        #10;    reg_s = 1;
                reg_len = 5;

        #10;    reg_s = 1;
                reg_len = 7;


        #10;
    end

endmodule
`endif