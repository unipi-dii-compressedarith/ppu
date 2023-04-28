module core_op_fma 
  import ppu_pkg::*;
#(
  /// Posit size. needed by `fir_to_fixed`.
  parameter N       = -1,

  parameter TE_BITS = -1,
  parameter MANT_SIZE = -1,
  parameter FRAC_FULL_SIZE = -1
) (
  input                         clk_i,
  input                         rst_i,
  input operation_e             op_i,
  
  input fir_t                   fir1_i,
  input fir_t                   fir2_i,
  input fir_t                   fir3_i,
  

  output logic                  sign_o,
  output exponent_t             te_o,
  output [(FRAC_FULL_SIZE)-1:0] frac_o,
  
  output                        frac_truncated_o
);

  wire [(MANT_ADD_RESULT_SIZE)-1:0] mant_out_add_sub;
  wire [(MANT_MUL_RESULT_SIZE)-1:0] mant_out_mul;
  wire [(MANT_DIV_RESULT_SIZE)-1:0] mant_out_div;


  logic sign_out_add_sub, sign_out_mul, sign_out_div;
  exponent_t te_out_add_sub, te_out_mul, te_out_div;
  wire frac_truncated_add_sub, frac_truncated_mul, frac_truncated_div;

  
  core_mul #(
    .TE_BITS                (TE_BITS),
    .MANT_SIZE              (MANT_SIZE),
    .MANT_MUL_RESULT_SIZE   (MANT_MUL_RESULT_SIZE)
  ) core_mul_inst (
    .clk_i                  (clk_i),
    .rst_i                  (rst_i),
    .sign1_i                (fir1_i.sign),
    .sign2_i                (fir2_i.sign),
    .te1_i                  (fir1_i.total_exponent),
    .te2_i                  (fir2_i.total_exponent),
    .mant1_i                (fir1_i.mant),
    .mant2_i                (fir2_i.mant),
    .sign_o                 (sign_out_mul),
    .te_o                   (te_out_mul),
    .mant_o                 (mant_out_mul),
    .frac_truncated_o       (frac_truncated_mul)        // TODO: frac must eventually not be truncated.
  );


  localparam FX_M = 32;
  localparam FX_N = 128;
  logic [(1+FX_N)-1:0] mul_out_fixed, fir3_fixed;
  
  fir_to_fixed #(
    .N              (2*N-3),
    .FIR_TE_SIZE    ($bits(te_out_mul)),
    .FIR_FRAC_SIZE  ($bits(mant_out_mul)),
    .FX_M           (FX_M),
    .FX_N           (FX_N)
  ) fir_to_fixed_mul (
    .fir_i          ({sign_out_mul, te_out_mul, mant_out_mul}),
    .fixed_o        (mul_out_fixed)
  );


  fir_to_fixed #(
    .N              (N),
    .FIR_TE_SIZE    ($bits(fir3_i.total_exponent)),
    .FIR_FRAC_SIZE  ($bits(fir3_i.mant)),
    .FX_M           (FX_M),
    .FX_N           (FX_N)
  ) fir_to_fixed_fir3 (
    .fir_i          (fir3_i),
    .fixed_o        (fir3_fixed)
  );
  

  // fixed_to_fixed #(
  //   /// 
  //   .FX_M_IN (FX_M_IN),
  //   .FX_N_IN (FX_N_IN),
  //   ///
  //   .FX_M_OUT (FX_M_OUT),
  //   .FX_N_OUT (FX_N_OUT)
  // )(
  //   .fixed_i (fir3_fixed),
  //   .fixed_o (fir3_fixed_aligned)
  // );


  logic start;

  accumulator #(
    .FIXED_SIZE   ($bits(mul_out_fixed))
  ) accumulator_inst (
    .clk_i        (clk_i),
    .rst_i        (rst_i),
    .start_i      (start),
    .init_value_i (fir3_fixed),
    .fixed_i      (mul_out_fixed),
    .fixed_o      ()
  );





  // add_sub #(
  //   .TE_BITS                (TE_BITS),
  //   .MANT_SIZE              (MANT_SIZE),
  //   .MANT_ADD_RESULT_SIZE   (MANT_ADD_RESULT_SIZE)
  // ) add_sub_inst (
  //   .clk_i                  (clk_i),
  //   .rst_i                  (rst_i),
    
  //   .sign1_i                (fir1_i.sign),
  //   .sign2_i                (fir2_i.sign),
  //   .te1_i                  (fir1_i.total_exponent),
  //   .te2_i                  (fir2_i.total_exponent),
  //   .mant1_i                (fir1_i.mant),
  //   .mant2_i                (fir2_i.mant),

  //   .sign_o                 (sign_out_add_sub),
  //   .te_o                   (te_out_add_sub),
  //   .mant_o                 (mant_out_add_sub),
  //   .frac_truncated_o       (frac_truncated_add_sub)
  // );



  // core_div #(
  //   .TE_BITS                (TE_BITS),
  //   .MANT_SIZE              (MANT_SIZE),
  //   .MANT_DIV_RESULT_SIZE   (MANT_DIV_RESULT_SIZE)
  // ) core_div_inst (
  //   .clk_i                  (clk_i),
  //   .rst_i                  (rst_i),
  //   .sign1_i                (fir1_i.sign),
  //   .sign2_i                (fir2_i.sign),
  //   .te1_i                  (fir1_i.total_exponent),
  //   .te2_i                  (fir2_i.total_exponent),
  //   .mant1_i                (fir1_i.mant),
  //   .mant2_i                (fir2_i.mant),
  //   .sign_o                 (sign_out_div),
  //   .te_o                   (te_out_div),
  //   .mant_o                 (mant_out_div),
  //   .frac_truncated_o       (frac_truncated_div)
  // );






  // wire [(FRAC_FULL_SIZE)-1:0] mant_out_core_op;
  // assign mant_out_core_op = (op_i == ADD || op_i == SUB)
  //   ? mant_out_add_sub << (FRAC_FULL_SIZE - MANT_ADD_RESULT_SIZE) : op_i == MUL
  //   ? mant_out_mul << (FRAC_FULL_SIZE - MANT_MUL_RESULT_SIZE) : /* op_i == DIV */
  //     mant_out_div;


  // assign sign_o = (op_i == ADD || op_i == SUB)
  //   ? sign_out_add_sub : op_i == MUL
  //   ? sign_out_mul : /* op_i == DIV */
  //     sign_out_div;

  
  // assign te_o = (op_i == ADD || op_i == SUB)
  //   ? te_out_add_sub : op_i == MUL
  //   ? te_out_mul : /* op_i == DIV */
  //     te_out_div;


  // // chopping off the two MSB representing the
  // // non-fractional components i.e. ones and tens.
  // assign frac_o = op_i == DIV
  //   ? mant_out_core_op : /* ADD, SUB, and MUL */
  //     mant_out_core_op << 2;


  // assign frac_truncated_o = op_i == MUL
  //   ? frac_truncated_mul : op_i == DIV
  //   ? frac_truncated_div : /* op_i == ADD || op_i == SUB */
  //     frac_truncated_add_sub;



endmodule: core_op_fma







/*
make -f Makefile_new.mk TOP=tb_core_op_fma
*/
module tb_core_op_fma #(
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
  initial f2 = $fopen("tb_core_op_fma.log", "w");


  initial begin
    $dumpfile("tb_core_op_fma");
    $dumpvars(0, tb_core_op_fma);
  end

  logic [128:0] fixed_o;

  initial begin
    for (int i=0; i<5; i++) begin
      @(posedge clk_i);
      
      if (i == 0) begin
        force ppu_inst.ppu_core_ops_inst.ops_inst.core_op_fma_inst.start = 1;
      end else begin
        force ppu_inst.ppu_core_ops_inst.ops_inst.core_op_fma_inst.start = 0;
      end
      
      op_i = FMADD;
      /* P<16,1>(16384) === 1.0 , for easy test */
      operand1_i = 18432; // 18432 == 1.5     //$urandom%(1 << 16);
      operand2_i = 27776; // 27776 == 12.5    //$urandom%(1 << 16);
      operand3_i = 27136; // 27136 == 10.0    //$urandom%(1 << 16);

      //@(posedge clk_i);
      fixed_o = ppu_inst.ppu_core_ops_inst.ops_inst.core_op_fma_inst.accumulator_inst.fixed_o;

      $display("(0x%h, 0x%h, 0x%h) 0x%h", operand1_i, operand2_i, operand3_i, fixed_o);

      $fwrite(f2, "(0x%h, 0x%h, 0x%h) 0x%h %t\n", operand1_i, operand2_i, operand3_i, fixed_o, $time);

    end

    #100;
    $finish;
  end

  
endmodule: tb_core_op_fma
