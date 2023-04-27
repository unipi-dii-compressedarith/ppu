module fir_to_fixed
#(
  /// Posit 
  /// In the future remove dependency from Posit size.
  parameter N             = -1,

  /// FIR parameters
  parameter FIR_TE_SIZE   = -1,
  parameter FIR_FRAC_SIZE = -1,
  
  /// Fixed point parameters (Fx<M,N>) without sign
  parameter FX_M = -1,
  parameter FX_N = -1
)(
  input   logic[(1+FIR_TE_SIZE+FIR_FRAC_SIZE)-1:0]    fir_i,
  output  logic[(1+FX_N)-1:0]                         fixed_o
);

  logic                           fir_sign;
  logic signed [FIR_TE_SIZE-1:0]  fir_te;
  logic [FIR_FRAC_SIZE-1:0]       fir_frac;
  assign {fir_sign, fir_te, fir_frac} = fir_i;


  logic[(1+FX_N)-1:0] fixed_tmp;
  
/*
  logic                   fixed_sign;
  logic [FX_M-1:0]        fixed_integer;
  logic [(FX_N-FX_M)-1:0] fixed_fraction;
  
  
  assign fixed_integer = fixed_tmp >> fir_te;
  assign fixed_fraction = fixed_tmp[(FX_N-FX_M)-1:0];
  assign fixed_sign = fir_sign;

  assign fixed_o = {fixed_sign, fixed_integer, fixed_fraction};
*/

  localparam MANT_MAX_LEN = N - 1 - 2; // -1: sign lenght, -2: regime min length

  assign fixed_tmp = fir_frac << (FX_N - (FX_M-1) - (MANT_MAX_LEN+1));

  logic fir_te_sign;
  assign fir_te_sign = fir_te >= 0;

  assign fixed_o = (fir_te >= 0) ? (fixed_tmp << fir_te) : (fixed_tmp >> (-fir_te));


  /// Adding sign


endmodule: fir_to_fixed





/*
make -f Makefile_new.mk TOP=tb_fir_to_fixed
*/
module tb_fir_to_fixed #(
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

  ppu #(
    .WORD         (WORD),
    `ifdef FLOAT_TO_POSIT
      .FSIZE        (FSIZE),
    `endif
    .N            (N),
    .ES           (ES)
  ) ppu_inst (
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

  ////// log to file //////
  integer f2;
  initial f2 = $fopen("tb_fir_to_fixed.log", "w");



  initial begin
    $dumpfile("tb_fir_to_fixed");
    $dumpvars(0, tb_fir_to_fixed);
  end

  logic [128:0] fixed_o;

  initial begin
    for (int i=0; i<20; i++) begin
      @(posedge clk_i);
      op_i = MUL;
      operand2_i = $urandom%(1 << 16);

      @(posedge clk_i);
      fixed_o = ppu_inst.ppu_core_ops_inst.fir_to_fixed_inst.fixed_o;

      $display("%d, %d", operand2_i, fixed_o);

      $fwrite(f2, "%d %d %t\n", operand2_i, fixed_o, $time);

    end

    #100;
    $finish;
  end

  
endmodule: tb_fir_to_fixed
