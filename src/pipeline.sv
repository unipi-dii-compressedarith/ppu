module pipeline #(
  parameter PIPE_DEPTH = 2,
  parameter DATA_WIDTH = 32 
)(
  input logic                     clk_i,
  input logic                     rst_i,
  input logic   [DATA_WIDTH-1:0]  data_in,
  output logic  [DATA_WIDTH-1:0]  data_out
);

  
  generate
    if (PIPE_DEPTH == 0) begin
      assign data_out = data_in;
    end else begin
      
      // (*retiming_backward = 1 *) 
      logic [DATA_WIDTH-1:0] pipeline_reg [PIPE_DEPTH-1:0] /*synthesis preserve*/;

      always_ff @(posedge clk_i) begin
        if (rst_i) begin
          for (int i = 0; i < PIPE_DEPTH; i++) begin
            pipeline_reg[i] <= 'b0;
          end
        end else begin
          pipeline_reg[0] <= data_in; 
          for (int i = 1; i < PIPE_DEPTH; i++) begin
            pipeline_reg[i] <= pipeline_reg[i-1];
          end
        end
      end

      assign data_out = pipeline_reg[PIPE_DEPTH-1];

    end
  endgenerate
  
  
endmodule: pipeline
