module reg_banks (
  input                clk,
  input                rst,
  input                stall_i,
  input                delay_op,   // for division
  input [FIR_SIZE-1:0] fir1_in,
  input [FIR_SIZE-1:0] fir2_in,
  input [ OP_BITS-1:0] op_in,
  input [   (N+1)-1:0] special_in,

  output logic [FIR_SIZE-1:0] fir1_out,
  output logic [FIR_SIZE-1:0] fir2_out,
  output logic [ OP_BITS-1:0] op_out,
  output logic [   (N+1)-1:0] special_out
);

  logic [OP_BITS-1:0] op_intermediate;

`ifdef PIPELINE_STAGE
  always_ff @(posedge clk) begin
    if (rst) begin
      fir1_out <= 0;
      fir2_out <= 0;
      op_intermediate <= 0;
      op_out <= 0;
      special_out <= 0;
    end else begin
      fir1_out <= stall_i ? fir1_out : fir1_in;
      fir2_out <= stall_i ? fir2_out : fir2_in;
      op_intermediate <= stall_i ? op_intermediate : op_in;
      op_out <= delay_op ? (stall_i ? op_intermediate : op_in) : op_intermediate;
      special_out <= stall_i ? special_out : special_in;
    end
  end
`else
  assign fir1_out =           stall_i ? fir1_out : fir1_in;
  assign fir2_out =           stall_i ? fir2_out : fir2_in;
  assign op_intermediate =    stall_i ? op_intermediate : op_in;
  assign op_out =             delay_op ? (stall_i ? op_intermediate : op_in) : op_intermediate;
  assign special_out =        stall_i ? special_out : special_in;
`endif

endmodule: reg_banks
