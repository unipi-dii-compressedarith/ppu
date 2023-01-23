module handle_special #(
    parameter N = `N
) (
    input posit_t               p1,
    input posit_t               p2,
    input        [OP_BITS-1:0]  op,
    input                       p1_is_zero,
    input                       p2_is_zero,
    input                       p1_is_nar,
    input                       p2_is_nar,
    output posit_t              pout
);

    wire [N-1:0] nan;
    assign nan = ({{1{1'b1}}, {N - 1{1'b0}}});

    always_comb @(*) begin
        case (op)
            ADD: begin  // +
                if (p1_is_nar || p2_is_nar) begin
                    pout = nan;
                end else if (p1_is_zero) begin
                    pout = p2;
                end else if (p2_is_zero) begin
                    pout = p1;
                end else begin
                    pout = 'bX;  //
                end
            end
            SUB: begin  // -
                if (p1_is_nar || p2_is_nar) begin
                    pout = nan;
                end else if (p1_is_zero && p2_is_zero) begin
                    pout = 0;
                end else if (p1_is_zero) begin
                    pout = p2 ^ nan;  // toggles sign bit
                end else if (p2_is_zero) begin
                    pout = p1;
                end else begin
                    pout = 'bX;  //
                end
            end
            MUL: begin  // *
                if (p1_is_nar || p2_is_nar) begin
                    pout = nan;
                end else if (p1_is_zero || p2_is_zero) begin
                    pout = 0;
                end else begin
                    pout = 'bX;  //
                end
            end
            DIV: begin  // /
                if (p1_is_nar || p2_is_nar || p2_is_zero) begin
                    pout = nan;
                end else if (p1_is_zero) begin
                    pout = 0;
                end else begin
                    pout = 'bX;  //
                end
            end
        endcase
    end

endmodule
