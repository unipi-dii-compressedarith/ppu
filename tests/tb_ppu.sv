/// PPU test bench
module tb_ppu;
  
  import ppu_pkg::*;

  parameter WORD = `WORD;
  parameter N = `N;
  parameter ES = `ES;
  parameter FSIZE = `F;

  parameter ASCII_SIZE = 300;

  reg                 clk;
  reg                 rst;
  reg                 valid_in;
  reg  [    WORD-1:0] in1;
  reg  [    WORD-1:0] in2;
  reg  [ OP_SIZE-1:0] op;
  reg  [ASCII_SIZE:0] op_ascii;
  wire [    WORD-1:0] out;
  wire                valid_o;


  reg [ASCII_SIZE:0] in1_ascii, in2_ascii, out_ascii, out_gt_ascii;


  reg [WORD-1:0] out_ground_truth;
  reg [N-1:0] pout_hwdiv_expected;
  reg diff_out_ground_truth, diff_pout_hwdiv_exp, pout_off_by_1;
  reg [  N:0] test_no;

  reg [100:0] count_errors;

  ppu #(
    .WORD(WORD),
`ifdef FLOAT_TO_POSIT
    .FSIZE(FSIZE),
`endif
    .N(N),
    .ES(ES)
  ) ppu_inst (
    .clk(clk),
    .rst(rst),
    .valid_in(valid_in),
    .in1(in1),
    .in2(in2),
    .op(op),
    .out(out),
    .valid_o(valid_o)
  );


  // `define STRINGIFY(DEFINE) $sformatf("%0s", `"DEFINE`")

  
  initial clk = 0;
  initial rst = 0;
  
  always begin clk = ~clk; #5; end

  always @(*) begin
    diff_out_ground_truth = out === out_ground_truth ? 0 : 1'bx;
    pout_off_by_1 = abs(out - out_ground_truth) == 0 ? 0 :
                    abs(out - out_ground_truth) == 1 ? 1 : 'bx;
    diff_pout_hwdiv_exp = (op != DIV) ? 'hz : 
                          out === pout_hwdiv_expected ? 0 : 1'bx;
  end


  //////////////////////////////////////////////////////////////////
  ////// log to file //////
  integer f;
  initial f = $fopen("ppu_output.log", "w");

  always @(posedge clk) begin
    if (valid_in) $fwrite(f, "i %h %h %h\n", in1, op, in2);
  end

  always @(negedge clk) begin
    if (valid_o) $fwrite(f, "o %h\n", out);
  end
  //////////////////////////////////////////////////////////////////

  initial begin

    // $dumpfile({"tb_ppu_P", `STRINGIFY(`N), "E", `STRINGIFY(`ES), ".vcd"});
    $dumpfile({"tb_ppu.vcd"});
    $dumpvars(0, tb_ppu);
    #7;

    valid_in = 1;

    
    
    `include "sim/test_vectors/tv_posit_ppu.sv"

    
    
    
    
    
    /*
    if (N == 4 && ES == 0) begin
        `include "../test_vectors/tv_posit_ppu_P4E0.sv"
    end

    if (N == 5 && ES == 1) begin
        `include "../test_vectors/tv_posit_ppu_P5E1.sv"
    end

    if (N == 8 && ES == 0) begin
        `include "../test_vectors/tv_posit_ppu_P8E0.sv"
    end

    if (N == 8 && ES == 1) begin
        `include "../test_vectors/tv_posit_ppu_P8E1.sv"
    end

    if (N == 8 && ES == 2) begin
        `include "../test_vectors/tv_posit_ppu_P8E2.sv"
    end

    if (N == 16 && ES == 0) begin
        `include "../test_vectors/tv_posit_ppu_P16E0.sv"
    end

    if (N == 16 && ES == 1) begin
        `include "../test_vectors/tv_posit_ppu_P16E1.sv"
    end

    if (N == 16 && ES == 2) begin
        `include "../test_vectors/tv_posit_ppu_P16E2.sv"
    end

    if (N == 32 && ES == 2) begin
        `include "../test_vectors/tv_posit_ppu_P32E2.sv"
    end
    */

    #10;
    $finish;
  end

endmodule: tb_ppu
