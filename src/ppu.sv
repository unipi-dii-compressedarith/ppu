`define WORD 64
module ppu #(
        parameter WORD = `WORD,
`ifdef FLOAT_TO_POSIT        
        parameter FSIZE = `F,
`endif
        parameter N = `N,
        parameter ES = `ES
    )(
        input [WORD-1:0] in1,
        input [WORD-1:0] in2,
        input [OP_SIZE-1:0] op, /*
                              ADD
                            | SUB
                            | MUL
                            | DIV
                            | F2P
                            | P2F
                            */
        output [WORD-1:0] out
    );

    wire [N-1:0] p1, p2, posit;
    
    assign p1 = in1[N-1:0];
    assign p2 = in2[N-1:0];


    ppu_core_ops #(
        .N(N),
        .ES(ES)
    ) ppu_core_ops_inst (
        .p1(p1),
        .p2(p2),
        .op(op),
`ifdef FLOAT_TO_POSIT
        .float_pif(float_pif),
        .posit_pif(posit_pif),
`endif
        .pout(posit)
    );

`ifdef FLOAT_TO_POSIT
    wire [(1 + FLOAT_EXP_SIZE_F`F + FLOAT_MANT_SIZE_F`F)-1:0] float_pif;
`endif
    wire [PIF_SIZE-1:0] posit_pif;


`ifdef FLOAT_TO_POSIT
    wire [FSIZE-1:0] float_in, float_out;
    assign float_in = in1[FSIZE-1:0];

    float_to_pif #(
        .FSIZE(FSIZE)
    ) float_to_pif_inst (
        .bits(float_in),
        .pif(float_pif)
    );


    wire [FSIZE-1:0] float;
    pif_to_float #(
        .N(N),
        .ES(ES),
        .FSIZE(FSIZE)
    ) pif_to_float_inst (
        .pif(posit_pif),
        .float(float_out)
    );
`endif
    
    assign out = 
`ifdef FLOAT_TO_POSIT
        (op == POSIT_TO_FLOAT) ? float_out : 
`endif
        posit;


endmodule
