module fixed_to_fir
#(
  /// Posit 
  /// In the future remove dependency from Posit size.
  parameter N             = -1,

  /// FIR parameters
  parameter FIR_TE_SIZE   = -1,
  parameter FIR_FRAC_SIZE = -1,
  
  /// Fixed point parameters (Fx<M,N>) without sign
  parameter FX_M = -1,
  parameter FX_B = -1
)(
  input  logic[(FX_B)-1:0]                         fixed_i,
  output logic[(1+FIR_TE_SIZE+FIR_FRAC_SIZE)-1:0]    fir_o
);

  logic                           fir_sign;
  logic signed [FIR_TE_SIZE-1:0]  fir_te;
  logic [FIR_FRAC_SIZE-1:0]       fir_frac;


  logic [$clog2(FX_B)-1:0] lzc_fixed;
  logic lzc_valid;

  lzc #(
    .NUM_BITS   (FX_B)
  ) lzc_inst (
    .bits_i     (fixed_i),
    .lzc_o      (lzc_fixed),
    .valid_o    (lzc_valid)
  );

  assign fir_sign = fixed_i[(FX_B)-1];
  assign fir_te = FX_M - lzc_fixed - 1;

  localparam MANT_MAX_LEN = N - 1 - 2; // -1: sign lenght, -2: regime min length

  assign fir_frac = {1'b1,                                                              // integer part
                    ((fixed_i >> fir_te) >> (FX_B - FX_M - (MANT_MAX_LEN + 1))) >> 1    // fractional part. ">> 1" is needed to make space for the integer part.
  };

  assign fir_o = {fir_sign, fir_te, fir_frac};

endmodule: fixed_to_fir





/*
make -f Makefile_new.mk TOP=tb_fixed_to_fir
*/
module tb_fixed_to_fir #(
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


  initial begin
    $dumpfile("tb_fixed_to_fir.vcd");
    $dumpvars(0, tb_fixed_to_fir);
  end

  logic [128:0] fixed_o;

  initial begin
    for (int i=0; i<20; i++) begin
      @(posedge clk_i);
      op_i = MUL;
      operand2_i = $urandom%(1 << 16);

      @(posedge clk_i);
      
      if (!(ppu_inst.ppu_core_ops_inst.fir2_st0 == ppu_inst.ppu_core_ops_inst.fixed_to_fir_inst.fir_o)) begin
        $display("Error: %d", ppu_inst.ppu_core_ops_inst.fir2_st0);
      end

      // $display("%d, %d", operand2_i, fixed_o);

    end

    #100;
    $finish;
  end

  
endmodule: tb_fixed_to_fir
