module sign_decisor (
    input                clk,
    input                rst,
    input                sign1,
    input                sign2,
    input  [OP_SIZE-1:0] op,
    output               sign
);

    // delayed by 1 cycle just like the 4 operations underneath.
    assign sign = 
        (op == ADD || op == SUB) 
        ? sign1_st1 : /* op == MUL  || op == DIV */
          sign1_st1 ^ sign2_st1;


    logic sign1_st1, sign2_st1;

    always_ff @(posedge clk) begin
        if (rst) begin
            sign1_st1 <= 0;
            sign2_st1 <= 0;
        end else begin
            sign1_st1 <= sign1;
            sign2_st1 <= sign2;
        end
    end

endmodule
