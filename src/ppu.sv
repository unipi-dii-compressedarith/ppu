/*


*/


module ppu #(
        parameter N = `N,
        parameter ES = `ES
    )(
        input clk,
        // input rst,
        input [N-1:0] p1,
        input [N-1:0] p2,
        input [OP_SIZE-1:0] op,
        output reg [N-1:0] pout
    );

    not_ppu #(
        .N(N),
        .ES(ES)
    ) not_ppu_inst (
        .p1(p1_reg),
        .p2(p2_reg),
        .op(op_reg),
        .pout(pout_reg)
    );

    reg [N-1:0] p1_reg, p2_reg, pout_reg;
    reg [OP_SIZE-1:0] op_reg;

    
    always @(posedge clk) begin
        p1_reg <= p1;
        p2_reg <= p2;
        op_reg <= op;
        pout <= pout_reg;    
    end

endmodule
