/// PPU test bench
module tb_ppu #(
  parameter CLK_FREQ = `CLK_FREQ
);

  import ppu_pkg::*;

  parameter WORD = `WORD;
  parameter N = `N;
  parameter ES = `ES;
  parameter FSIZE = `F;

  localparam ASCII_SIZE = 300;

  logic                                 clk_i;
  logic                                 rst_i;
  logic                                 in_valid_i;
  logic                   [WORD-1:0]    operand1_i;
  logic                   [WORD-1:0]    operand2_i;
  logic                   [WORD-1:0]    operand3_i;
  ppu_pkg::operation_e                  op_i;
  logic                 [ASCII_SIZE:0]  op_i_ascii;
  wire                  [WORD-1:0]      result_o;
  wire                                  out_valid_o;


  logic [ASCII_SIZE-1:0]  operand1_i_ascii,   // operand1_i
                          operand2_i_ascii,   // operand2_i
                          operand3_i_ascii,   // operand3_i
                          result_o_ascii,     // result_o ascii
                          result_gt_ascii;    // result ground truth ascii


  logic [WORD-1:0] out_ground_truth;
  logic [N-1:0] pout_hwdiv_expected;
  logic diff_out_ground_truth, diff_pout_hwdiv_exp, pout_off_by_1;
  logic [  N:0] test_no;

  logic [100:0] count_errors;


  clk_gen #(
    .CLK_FREQ     (CLK_FREQ)
  ) clk_gen_i (
    .clk_o        (clk_i)
  );  


  ppu_top #(
    .WORD         (WORD),
    `ifdef FLOAT_TO_POSIT
      .FSIZE        (FSIZE),
    `endif
    .N            (N),
    .ES           (ES)
  ) ppu_top_inst (
    .clk_i        (clk_i),
    .rst_i        (rst_i),
    .in_valid_i   (in_valid_i),
    .operand1_i   (operand1_i),
    .operand2_i   (operand2_i),
    .operand3_i   (operand3_i),
    .op_i         (op_i),
    .result_o     (result_o),
    .out_valid_o  (out_valid_o)
  );

  
  initial begin
    $display("Posit format: P<%0d,%0d>", N, ES);
    $display("Float support: F<%0d>", FSIZE);
    $display("F = %0d", FSIZE);
    $display("WORD = %0d", WORD);
    $display("CLK_FREQ = %0d MHz", CLK_FREQ);
  end


  // `define STRINGIFY(DEFINE) $sformatf("%0s", `"DEFINE`")
  
  initial rst_i = 0;
  
  
  always @(*) begin
    diff_out_ground_truth = result_o === out_ground_truth ? 0 : 1'bx;
    pout_off_by_1 = abs(result_o - out_ground_truth) == 0 ? 0 :
                    abs(result_o - out_ground_truth) == 1 ? 1 : 'bx;
    diff_pout_hwdiv_exp = (op_i != DIV) ? 'hz : 
                          result_o === pout_hwdiv_expected ? 0 : 1'bx;
  end


  //////////////////////////////////////////////////////////////////
  ////// log to file //////
  integer f;
  initial f = $fopen("ppu_output.log", "w");

  always @(posedge clk_i) begin
    if (in_valid_i) $fwrite(f, "i %h %h %h %t\n", operand1_i, op_i, operand2_i, $time);
  end

  always @(posedge clk_i) begin
    if (out_valid_o) $fwrite(f, "o %h %t\n", result_o, $time);
  end
  //////////////////////////////////////////////////////////////////

  initial begin: vcd_file
    // $dumpfile({"tb_ppu_P", `STRINGIFY(`N), "E", `STRINGIFY(`ES), ".vcd"});
    $dumpfile({"tb_ppu.vcd"});
    $dumpvars(0, tb_ppu);
  end

  initial begin: sequences
    in_valid_i = 1'b0;
    @(posedge clk_i);
  

    // test vector posit ppu must be generated any time 
    // any of the parameter changes.
    // run `make -f Makefile_new.mk gen-test-vectors`
    `include "sim/test_vectors/tv_posit_ppu.sv"
    

    @(negedge clk_i);
    in_valid_i = 1'b0;
    for (int i=0; i<4; i++) begin
      @(negedge clk_i);
    end
    
    $finish;
  end

endmodule: tb_ppu

