module add_sub 
  import ppu_pkg::*;
#(
  parameter TE_BITS = -1,
  parameter MANT_SIZE = -1,
  parameter MANT_ADD_RESULT_SIZE = -1
) (
  input logic                         clk_i,
  input logic                         rst_i,

  input logic                         sign1_i,
  input logic                         sign2_i,
  input exponent_t                    te1_i,
  input exponent_t                    te2_i,
  input  [             MANT_SIZE-1:0] mant1_i,
  input  [             MANT_SIZE-1:0] mant2_i,
  
  output logic                        sign_o,
  output exponent_t                   te_o,
  output [(MANT_ADD_RESULT_SIZE)-1:0] mant_o,
  
  output                              frac_truncated_o
);

  
  logic                 sign1, sign2;
  exponent_t            te1, te2;
  logic [MANT_SIZE-1:0] mant1, mant2;

  
  router_core_add_sub #(
    .SIZE       (1+TE_BITS+MANT_SIZE)
) router_core_add_sub_i (
    .port1_i    ({sign1_i, te1_i, mant1_i}),
    .port2_i    ({sign2_i, te2_i, mant2_i}),
    .port1_o    ({sign1, te1, mant1}),
    .port2_o    ({sign2, te2, mant2})
);



  core_add_sub #(
    .TE_BITS              (TE_BITS),
    .MANT_SIZE            (MANT_SIZE),
    .MANT_ADD_RESULT_SIZE (MANT_ADD_RESULT_SIZE)
  ) core_add_sub_i (
    .clk_i                (clk_i),
    .rst_i                (rst_i),
    
    .sign1_i              (sign1),
    .sign2_i              (sign2),
    .te1_i                (te1),
    .te2_i                (te2),
    .mant1_i              (mant1),
    .mant2_i              (mant2),
  
    .sign_o               (sign_o),
    .te_o                 (te_o),
    .mant_o               (mant_o),
  
    .frac_truncated_o     (frac_truncated_o)
);




endmodule: add_sub
