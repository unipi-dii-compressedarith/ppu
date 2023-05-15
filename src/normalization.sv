module normalization 
  import ppu_pkg::*;
#(
  parameter N               = -1,
  parameter ES              = -1,

  parameter FIR_TOTAL_SIZE  = -1,

  parameter TE_BITS         = -1,
  parameter FRAC_FULL_SIZE  = -1
) (
  input ops_out_meta_t  ops_result_i,
  input posit_special_t p_special_i,
  output posit_t        posit_o
);


  posit_t pout_non_special;
  
  fir_to_posit #(
    .N                (N),
    .ES               (ES),
    .FIR_TOTAL_SIZE   (FIR_TOTAL_SIZE)
  ) fir_to_posit_inst (
    .ops_result_i     (ops_result_i),
    .posit_o          (pout_non_special)
  );




  assign is_special_or_trivial = p_special_i.special_tag;
  assign pout_special_or_trivial = p_special_i.posit;



  assign posit_o = is_special_or_trivial ? pout_special_or_trivial : pout_non_special;


endmodule: normalization
