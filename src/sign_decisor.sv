module sign_decisor (
    input                clk,
    input                rst,
    input                sign1,
    input                sign2,
    input  [OP_SIZE-1:0] op,
    output               sign
);

    assign sign = sign1_reg ^ sign2_reg; // delayed by 1 cycle just like the 4 operations underneath.


    logic sign1_reg, sign2_reg;

    always_ff @(posedge clk) begin
        if (rst) begin
            sign1_reg <= 0;
            sign2_reg <= 0;
        end else begin
            sign1_reg <= sign1;
            sign2_reg <= sign2;
        end
    end

endmodule
