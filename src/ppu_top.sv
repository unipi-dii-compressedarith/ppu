// /// A wrapper around the actual ppu.
// module ppu_top 
//   import ppu_pkg::*;
// #(
//   parameter WORD = `WORD,
// `ifdef FLOAT_TO_POSIT
//   parameter FSIZE = `F,
// `endif
//   parameter N = `N,
//   parameter ES = `ES
// ) (
//   input  logic                    clk_i,
//   input  logic                    rst_i,
//   input  logic                    in_valid_i,
//   input  logic        [WORD-1:0]  operand1_i,
//   input  logic        [WORD-1:0]  operand2_i,
//   input  logic        [WORD-1:0]  operand3_i,
//   input  operation_e              op_i,
//   output logic        [WORD-1:0]  result_o,
//   output logic                    out_valid_o
// );


//   logic [WORD-1:0] operand1_st0_reg, operand2_st0_reg, operand3_st0_reg;
//                    // operand1_st1_reg, operand2_st1_reg, operand3_st1_reg;
//   logic [WORD-1:0] result_st0_reg,
//                    result_st1_reg;
//   logic [OP_BITS-1:0] op_st0_reg;
//                       // op_st1_reg;
//   logic in_valid_st0_reg;
//         // in_valid_st1_reg;
//   logic out_valid_st0_reg,
//         out_valid_st1_reg;

//   ppu #(
//     .WORD           (WORD),
//     `ifdef FLOAT_TO_POSIT
//       .FSIZE        (FSIZE),
//     `endif
//     .N              (N),
//     .ES             (ES)
//   ) ppu_inst (
//     .clk_i          (clk_i),
//     .rst_i          (rst_i),
//     .in_valid_i     (in_valid_st0_reg),
//     .operand1_i     (operand1_st0_reg),
//     .operand2_i     (operand2_st0_reg),
//     .operand3_i     (operand3_st0_reg),
//     .op_i           (operation_e'(op_st0_reg)),
//     .result_o       (result_st0_reg),
//     .out_valid_o    (out_valid_st0_reg)
// );


// always_ff @(posedge clk_i) begin
//   if (rst_i) begin
//     // inputs
//     in_valid_st0_reg <= '0;
//     operand1_st0_reg <= '0;
//     operand2_st0_reg <= '0;
//     operand3_st0_reg <= '0;
//     op_st0_reg <= '0;
//     // outputs

//     out_valid_st1_reg <= '0;
//     result_st1_reg <= '0;

//     out_valid_o <= '0;
//     result_o <= '0;
//   end else begin
//     // inputs
//     in_valid_st0_reg <= in_valid_i;
//     operand1_st0_reg <= operand1_i;
//     operand2_st0_reg <= operand2_i;
//     operand3_st0_reg <= operand3_i;
//     op_st0_reg <= op_i;
//     // outputs
    
//     out_valid_st1_reg <= out_valid_st0_reg;
//     result_st1_reg <= result_st0_reg;

//     out_valid_o <= out_valid_st1_reg;
//     result_o <= result_st1_reg;
//   end
// end

// endmodule: ppu_top



///////////////////////////////////////////////////////////////////////


/// A wrapper around the actual ppu.
module ppu_top 
  import ppu_pkg::*;
#(
  parameter PIPE_DEPTH  = `PIPE_DEPTH,
  parameter WORD        = `WORD,
`ifdef FLOAT_TO_POSIT
  parameter FSIZE       = `F,
`endif
  parameter N           = `N,
  parameter ES          = `ES
) (
  input  logic                    clk_i,
  input  logic                    rst_i,
  input  logic                    in_valid_i,
  input  logic        [WORD-1:0]  operand1_i,
  input  logic        [WORD-1:0]  operand2_i,
  input  logic        [WORD-1:0]  operand3_i,
  input  logic     [OP_BITS-1:0]  op_i,
  output logic        [WORD-1:0]  result_o,
  output logic                    out_valid_o
);

  logic [WORD-1:0] operand1_st0, operand2_st0, operand3_st0;

  logic [WORD-1:0] result_st0,
                   result_st1;
  logic [OP_BITS-1:0] op_st0;

  logic in_valid_st0;
        
  logic out_valid_st0,
        out_valid_st1;


`ifdef COCOTB_TEST
  initial begin
    $display("`COCOTB_TEST defined");

    $dumpfile ("ppu_top.vcd");
    $dumpvars (0, ppu_top);
    #1;
  end
`endif


  ppu #(
    .WORD           (WORD),
    `ifdef FLOAT_TO_POSIT
      .FSIZE        (FSIZE),
    `endif
    .N              (N),
    .ES             (ES)
  ) ppu_inst (
    .clk_i          (clk_i),
    .rst_i          (rst_i),
    .in_valid_i     (in_valid_st0),
    .operand1_i     (operand1_st0),
    .operand2_i     (operand2_st0),
    .operand3_i     (operand3_st0),
    .op_i           (operation_e'(op_st0)),
    .result_o       (result_st0),
    .out_valid_o    (out_valid_st0)
);


  // initial $display($bits(in_valid_i) + $bits(op_i) + 3*$bits(operand1_i));

  localparam PIPE_DEPTH_FRONT = PIPE_DEPTH >= 1 ? 1 : 0;
  localparam PIPE_DEPTH_BACK  = PIPE_DEPTH >= 1 ? (PIPE_DEPTH - PIPE_DEPTH_FRONT) : 0;

  initial $display("PIPE_DEPTH_FRONT = %0d", PIPE_DEPTH_FRONT);
  initial $display("PIPE_DEPTH_BACK = %0d", PIPE_DEPTH_BACK);

  pipeline #(
    .PIPE_DEPTH   (PIPE_DEPTH_FRONT),
    .DATA_WIDTH   ($bits(in_valid_i) + $bits(op_i) + 3*$bits(operand1_i))
  ) pipeline_in (
    .clk_i        (clk_i),
    .rst_i        (rst_i),
    .data_in      ({in_valid_i,   op_i,   operand1_i,   operand2_i,   operand3_i}),
    .data_out     ({in_valid_st0, op_st0, operand1_st0, operand2_st0, operand3_st0})
  );

  pipeline #(
    .PIPE_DEPTH   (PIPE_DEPTH_BACK),
    .DATA_WIDTH   ($bits(result_st0) + $bits(out_valid_st0))
  ) pipeline_out (
    .clk_i        (clk_i),
    .rst_i        (rst_i),
    .data_in      ({result_st0, out_valid_st0}),
    .data_out     ({result_o,   out_valid_o})
  );

  

endmodule: ppu_top


