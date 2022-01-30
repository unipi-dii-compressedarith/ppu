module handle_special #(
        parameter N = `N
    )(
        input [N-1:0] p1,
        input [N-1:0] p2,
        input [OP_SIZE-1:0] op,
        input p1_is_zero,
        input p2_is_zero,
        input p1_is_nan,
        input p2_is_nan,
        output logic [N-1:0] pout
    );

    wire [N-1:0] nan;
    assign nan = ( { {1{1'b1}}, {N-1{1'b0}} });    

    always @(*) begin
        case (op)
        2'b00: begin // +
            if (p1_is_nan || p2_is_nan) begin
                pout = nan;
            end else if (p1_is_zero) begin
                pout = p2;
            end else if (p2_is_zero) begin
                pout = p1;
            end else begin
                pout = 'bX; // 
            end
        end 
        2'b01: begin // - 
            if (p1_is_nan || p2_is_nan) begin
                pout = nan;
            end else if (p1_is_zero && p2_is_zero) begin
                pout = 0;
            end else if (p1_is_zero) begin
                pout = p2 ^ nan; // toggles sign bit
            end else if (p2_is_zero) begin
                pout = p1;
            end else begin
                pout = 'bX; // 
            end
        end
        2'b10: begin // *
            if (p1_is_nan || p2_is_nan) begin
                pout = nan;
            end else if (p1_is_zero || p2_is_zero) begin
                pout = 0;
            end else begin
                pout = 'bX; // 
            end
        end
        2'b11: begin // /
            if (p1_is_nan || p2_is_nan || p2_is_zero) begin
                pout = nan;
            end else if (p1_is_zero) begin
                pout = 0;
            end else begin
                pout = 'bX; // 
            end
        end
        endcase
    end

endmodule
