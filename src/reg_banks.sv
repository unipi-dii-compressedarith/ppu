module reg_banks (
    input                       clk,
    input                       rst,
    input        [FIR_SIZE-1:0] fir1_in,
    input        [FIR_SIZE-1:0] fir2_in,
    input        [ OP_SIZE-1:0] op_in,
    input        [   (N+1)-1:0] special_in,
    input                       stall,
    output logic [FIR_SIZE-1:0] fir1_out,
    output logic [FIR_SIZE-1:0] fir2_out,
    output logic [ OP_SIZE-1:0] op_out,
    output logic [   (N+1)-1:0] special_out
);

    always_ff @(posedge clk) begin
        if (rst) begin
            fir1_out <= 0;
            fir2_out <= 0;
            op_out <= 0;
            special_out <= 0;
        end else begin
            fir1_out <= stall ? fir1_out : fir1_in;
            fir2_out <= stall ? fir2_out : fir2_in;
            op_out <= stall ? op_out : op_in;
            special_out <= stall ? special_out : special_in;
        end
    end
endmodule
