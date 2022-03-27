module reg_banks (
    input                clk,
    input                rst,
    input                stall,
    input                dealy_op,   // for division
    input [FIR_SIZE-1:0] fir1_in,
    input [FIR_SIZE-1:0] fir2_in,
    input [ OP_SIZE-1:0] op_in,
    input [   (N+1)-1:0] special_in,

    output logic [FIR_SIZE-1:0] fir1_out,
    output logic [FIR_SIZE-1:0] fir2_out,
    output logic [ OP_SIZE-1:0] op_out,
    output logic [   (N+1)-1:0] special_out
);

    logic [OP_SIZE-1:0] op_intermediate;

    always_ff @(posedge clk) begin
        if (rst) begin
            fir1_out <= 0;
            fir2_out <= 0;
            op_intermediate <= 0;
            op_out <= 0;
            special_out <= 0;
        end else begin
            fir1_out <= stall ? fir1_out : fir1_in;
            fir2_out <= stall ? fir2_out : fir2_in;
            op_intermediate <= stall ? op_intermediate : op_in;
            op_out <= dealy_op ? (stall ? op_intermediate : op_in) : op_intermediate;
            special_out <= stall ? special_out : special_in;
        end
    end
endmodule
