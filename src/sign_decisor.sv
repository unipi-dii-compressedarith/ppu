module sign_decisor (
    input                clk,
    input                rst,
    input                sign1,
    input                sign2,
    input  [OP_SIZE-1:0] op,
    output               sign
);

    assign sign = 
        (op == ADD || op == SUB) 
        ? sign1 : op == MUL 
        ? sign1 ^ sign2 : /* op == DIV */
          sign1_reg ^ sign2_reg;


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
