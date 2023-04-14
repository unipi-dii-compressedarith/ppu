`include "src/include/registers.svh"


`timescale 1ns / 1ps

module fma 
  import ppu_pkg::*;
#(
  parameter TE_BITS = 7,              // <16,1> -> 7
  parameter MANT_SIZE = 14,           //  -> 14
  parameter MANT_ADD_RESULT_SIZE = 30 
) (
  input logic                         clk_i,
  input logic                         rst_i,
  input exponent_t                    te1_i,
  input exponent_t                    te2_i,
  input exponent_t                    te3_i,
  input  [             MANT_SIZE-1:0] mant1_i,
  input  [             MANT_SIZE-1:0] mant2_i,
  input  [             MANT_SIZE-1:0] mant3_i,
  input                               have_opposite_sign_i,
  output [(MANT_ADD_RESULT_SIZE)-1:0] mant_o,
  output exponent_t                   te_o,
  output                              frac_truncated_o
);


  logic frac_truncated_mul;

  logic  [             2*MANT_SIZE-1:0] mant_mul_st0, mant_mul_st1;

  exponent_t                    te_mul_st0, te_mul_st1;
  exponent_t                    te3_st1;

  logic  [             28-1:0] mant3_st0, mant3_st1;
  assign mant3_st0 = mant3_i << (28 - 14);


  `FF(te_mul_st1, te_mul_st0);
  `FF(mant_mul_st1, mant_mul_st0);
  `FF(mant3_st1, mant3_st0);
  `FF(te3_st1, te3_i);

  localparam  TE_BITS_MUL = 7,
              MANT_SIZE_MUL = 14,
              MANT_MUL_RESULT_SIZE = 28;

  core_mul #(
    .TE_BITS                (TE_BITS_MUL),
    .MANT_SIZE              (MANT_SIZE_MUL),
    .MANT_MUL_RESULT_SIZE   (MANT_MUL_RESULT_SIZE)
  ) core_mul_inst (
    .clk_i                  (clk_i),
    .rst_i                  (rst_i),
    .te1_i                  (te1_i),
    .te2_i                  (te2_i),
    .mant1_i                (mant1_i),
    .mant2_i                (mant2_i),
    .mant_o                 (mant_mul_st0),
    .te_o                   (te_mul_st0),
    .frac_truncated_o       (frac_truncated_mul)
  );


  localparam  TE_BITS_ADD_SUB = 7,
              MANT_SIZE_ADD_SUB = 28 ,
              MANT_ADD_SUB_RESULT_SIZE = 1+28*2; // 2 MS + 1
 

  core_add_sub #(
    .TE_BITS                (TE_BITS_ADD_SUB),
    .MANT_SIZE              (MANT_SIZE_ADD_SUB),
    .MANT_ADD_RESULT_SIZE   (MANT_ADD_SUB_RESULT_SIZE)
  ) core_add_sub_inst (
    .clk_i                  (clk_i),
    .rst_i                  (rst_i),
    .te1_i                  (te_mul_st1),
    .te2_i                  (te3_st1),
    .mant1_i                (mant_mul_st1),
    .mant2_i                (mant3_st1),
    .have_opposite_sign_i   (1'b0), // change
    .mant_o                 (mant_o),
    .te_o                   (te_o),
    .frac_truncated_o       (frac_truncated_o)
  );

  
endmodule: fma

module tb_fma;
  import ppu_pkg::*;

  parameter TE_BITS = 7,
            MANT_SIZE = 14,
            MANT_ADD_RESULT_SIZE = 30;


  typedef struct {
    logic                               clk;
    logic                               rst;
    exponent_t                          te1;
    exponent_t                          te2;
    exponent_t                          te3;
    logic [             MANT_SIZE-1:0]  mant1;
    logic [             MANT_SIZE-1:0]  mant2;
    logic [             MANT_SIZE-1:0]  mant3;
    logic                               have_opposite_sign;
    logic [(MANT_ADD_RESULT_SIZE)-1:0]  mant;
    exponent_t                          te;
    logic                               frac_truncated;
  } dut_t;

  dut_t dut;


  fma #(
    .TE_BITS                (TE_BITS),
    .MANT_SIZE              (MANT_SIZE),
    .MANT_ADD_RESULT_SIZE   (MANT_ADD_RESULT_SIZE) 
  ) fma_inst (
    .clk_i                  (dut.clk),
    .rst_i                  (dut.rst),
    .te1_i                  (dut.te1),
    .te2_i                  (dut.te2),
    .te3_i                  (dut.te3),
    .mant1_i                (dut.mant1),
    .mant2_i                (dut.mant2),
    .mant3_i                (dut.mant3),
    .have_opposite_sign_i   (dut.have_opposite_sign),
    .mant_o                 (dut.mant),
    .te_o                   (dut.te),
    .frac_truncated_o       (dut.frac_truncated)
  );

  initial begin
    dut.clk = 0;
    dut.rst = 1;
    #23;
    dut.rst = 0;
  end

  initial begin 
    $dumpfile("tb_fma.vcd");
    $dumpvars(0, tb_fma);  
  end

  always begin
    dut.clk = !dut.clk; #5;
  end

  localparam N = 10, M = 4;
  initial begin
    for (int i = M; i < N; i++) begin
      for (int j = M; j < N; j++) begin
        for (int k = M; k < N; k++) begin
          @(posedge dut.clk);
          #1;
          dut.mant1 = i;
          dut.mant2 = j;
          dut.mant3 = k;
        end
      end
    end

    $finish;
  end 

  initial begin
    for (int i = M; i < N; i++) begin
      for (int j = M; j < N; j++) begin
        for (int k = M; k < N; k++) begin
          @(posedge dut.clk);
          #1;
          dut.te1 = i;
          dut.te2 = j;
          dut.te3 = k;
        end
      end
    end
  end
endmodule: tb_fma
