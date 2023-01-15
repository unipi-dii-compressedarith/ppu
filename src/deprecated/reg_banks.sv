module reg_banks (
  input                       clk,
  input                       rst,
  input                       stall_i,
  input                       delay_op,   // for division
  input ppu_pkg::fir_t        fir1_in,
  input ppu_pkg::fir_t        fir2_in,
  input ppu_pkg::operation_e  op_in,
  input ppu_pkg::posit_t      special_in,

  output ppu_pkg::fir_t       fir1_out,
  output ppu_pkg::fir_t       fir2_out,
  output ppu_pkg::operation_e op_out,
  output ppu_pkg::posit_t     special_out
);

  ppu_pkg::operation_e op_intermediate;

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
