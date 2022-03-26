module ppu_control_unit (
    input                      clk,
    input                      rst,
    input                      valid_in,
    input        [OP_SIZE-1:0] op,
    output logic               stall,
    output logic               valid_o
);

    logic [OP_SIZE-1:0] op_prev;
    always_ff @(posedge clk) begin
        if (rst) begin
            stall   <= 0;
            op_prev <= 0;
        end else begin
            op_prev <= op;
            if (op_prev !== DIV && op === DIV) begin
                stall <= 0;  //stall <= 1;
            end else begin
                stall <= 0;
            end
        end
    end


    logic valid_in_st0, valid_in_st1, valid_in_st2, valid_in_st3;

    always_ff @(posedge clk) begin
        if (rst) begin
            valid_in_st0 <= 0;
            valid_in_st1 <= 0;
            valid_in_st2 <= 0;
            valid_in_st3 <= 0;
        end else begin
            valid_in_st0 <= valid_in;
            valid_in_st1 <= valid_in_st0;  // stall == 1'b1 ? valid_in_st1 : valid_in_st0;
            valid_in_st2 <= valid_in_st1;  // stall == 1'b1 ? 1'b0 : valid_in_st1;
            valid_in_st3 <= valid_in_st2;
        end
    end

    assign valid_o = valid_in_st3;
endmodule


