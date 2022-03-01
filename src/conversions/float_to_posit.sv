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

    float_decoder #(
        .FSIZE(FSIZE)
    ) float_decoder_inst (
        .bits(float_bits),
        .sign(sign),
        .exp(float_exp),
        .frac(frac)
    );
    
    parameter FLOAT_EXP_SIZE = FLOAT_EXP_SIZE_F`F;
    parameter FLOAT_MANT_SIZE = FLOAT_MANT_SIZE_F`F;


    wire [FLOAT_EXP_SIZE-1:0] float_exp;
    assign exp = float_exp[TE_SIZE-1:0];

    wire [FRAC_FULL_SIZE-1:0] frac_full;
    assign frac_full = frac >> (FLOAT_MANT_SIZE - FRAC_FULL_SIZE);


    wire [N-1:0] posit_pif_out;
    pif_to_posit #(
        .N(N),
        .ES(ES)
    ) pif_to_posit_inst (
        .te(exp),
        .frac_full(frac_full),
        .frac_lsb_cut_off(1'b0),
        .posit(posit_pif_out)
    );


    set_sign #(
        .N(N)
    ) set_sign_inst (
        .posit_in(posit_pif_out),
        .sign(sign),
        .posit_out(posit)
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
    always @(*) begin
        diff = posit == posit_expected? 0 : 1'bX;
    end


    initial begin
        $dumpfile({"tb_float_F",`STRINGIFY(`F),"_to_posit_P",`STRINGIFY(`N),"E",`STRINGIFY(`ES),".vcd"});
        $dumpvars(0, tb_float_to_posit);                        


    if (N == 16 && ES == 1 && FSIZE == 64) begin
        `include "../test_vectors/tv_posit_float_to_posit_P16E1.sv"
    end


    if (N == 8 && ES == 0 && FSIZE == 64) begin
    float_bits = 4631840980365643314;
ascii_x = "47.209617947486905";
ascii_exp = "5";
ascii_frac = "2140563428773426";
posit_expected = 8'd126;
#10;

float_bits = 4626500949098613190;
ascii_x = "20.63320684614316";
ascii_exp = "4";
ascii_frac = "1304131789113798";
posit_expected = 8'd125;
#10;

float_bits = 4635274441167615127;
ascii_x = "79.2116485221362";
ascii_exp = "6";
ascii_frac = "1070424603374743";
posit_expected = 8'd127;
#10;

float_bits = 4629417380945110077;
ascii_x = "30.994454160482054";
ascii_exp = "4";
ascii_frac = "4220563635610685";
posit_expected = 8'd126;
#10;

float_bits = 4623678552057686250;
ascii_x = "13.303019135917982";
ascii_exp = "3";
ascii_frac = "2985334375557354";
posit_expected = 8'd123;
#10;

float_bits = 4635352308009339646;
ascii_x = "80.31820289701497";
ascii_exp = "6";
ascii_frac = "1148291445099262";
posit_expected = 8'd127;
#10;

float_bits = 4640663550923604007;
ascii_x = "183.5910086175438";
ascii_exp = "7";
ascii_frac = "1955934731993127";
posit_expected = 8'd127;
#10;

float_bits = 4639836699239122197;
ascii_x = "160.0904702991617";
ascii_exp = "7";
ascii_frac = "1129083047511317";
posit_expected = 8'd127;
#10;

float_bits = 4639588369707242464;
ascii_x = "153.03252050108767";
ascii_exp = "7";
ascii_frac = "880753515631584";
posit_expected = 8'd127;
#10;

float_bits = 4631443540117886445;
ascii_x = "44.38563513806353";
ascii_exp = "5";
ascii_frac = "1743123181016557";
posit_expected = 8'd126;
#10;

float_bits = 4637253516576973904;
ascii_x = "107.33600163496271";
ascii_exp = "6";
ascii_frac = "3049500012733520";
posit_expected = 8'd127;
#10;

float_bits = 4632984741371391886;
ascii_x = "55.336528688290045";
ascii_exp = "5";
ascii_frac = "3284324434521998";
posit_expected = 8'd127;
#10;

float_bits = 4630056891745434951;
ascii_x = "34.53290585707378";
ascii_exp = "5";
ascii_frac = "356474808565063";
posit_expected = 8'd126;
#10;

float_bits = 4626670805634974040;
ascii_x = "21.236658486306027";
ascii_exp = "4";
ascii_frac = "1473988325474648";
posit_expected = 8'd125;
#10;

float_bits = 4631231652986189901;
ascii_x = "42.8800865157833";
ascii_exp = "5";
ascii_frac = "1531236049320013";
posit_expected = 8'd126;
#10;

float_bits = 4640730546108138241;
ascii_x = "185.4951262856121";
ascii_exp = "7";
ascii_frac = "2022929916527361";
posit_expected = 8'd127;
#10;

float_bits = 4640037022849862920;
ascii_x = "165.78400975568388";
ascii_exp = "7";
ascii_frac = "1329406658252040";
posit_expected = 8'd127;
#10;

float_bits = 4639880327826781196;
ascii_x = "161.33046934046467";
ascii_exp = "7";
ascii_frac = "1172711635170316";
posit_expected = 8'd127;
#10;

float_bits = 4639836667482039793;
ascii_x = "160.08956770859325";
ascii_exp = "7";
ascii_frac = "1129051290428913";
posit_expected = 8'd127;
#10;

float_bits = 4630641545917197086;
ascii_x = "38.68712360384801";
ascii_exp = "5";
ascii_frac = "941128980327198";
posit_expected = 8'd126;
#10;


        
    end

    end


endmodule
`endif
