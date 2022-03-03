/*


*/

module ppu #(
        parameter N = `N,
        parameter ES = `ES
`ifdef FLOAT_TO_POSIT
        ,parameter FSIZE = `F
`endif
    )(
        input clk,
        // input rst,
        input [N-1:0] p1,
        input [N-1:0] p2,
`ifdef FLOAT_TO_POSIT
        input [FSIZE-1:0] float,
`endif
        input [OP_SIZE-1:0] op,
        output reg [N-1:0] pout
    );

    ppu_core_ops #(
        .N(N),
        .ES(ES)
    ) ppu_core_ops_inst (
        .p1(p1_reg),
        .p2(p2_reg),

        .float_pif(float_pif),
        .posit_pif(posit_pif),
        
        .op(op_reg),
        .pout(pout_reg)
    );


    reg [N-1:0] p1_reg, p2_reg, pout_reg;
`ifdef FLOAT_TO_POSIT
    reg [FSIZE-1:0] float_reg;
`endif
    reg [OP_SIZE-1:0] op_reg;

    
    always @(posedge clk) begin
        p1_reg <= p1;
        p2_reg <= p2;
`ifdef FLOAT_TO_POSIT
        float_reg <= float;
`endif
        op_reg <= op;
        pout <= pout_reg;    
    end

endmodule
