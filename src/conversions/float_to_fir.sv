module float_to_fir 
  import ppu_pkg::*;
#(
  parameter FSIZE = 64
)(
  input                                                       clk_i,
  input                                                       rst_i,
  input [FSIZE-1:0]                                           bits_i,
  output [(1 + FLOAT_EXP_SIZE_F`F + FLOAT_MANT_SIZE_F`F)-1:0] fir_o
  );

  logic sign_st0, sign_st1;
  logic signed [FLOAT_EXP_SIZE_F`F-1:0] exp_st0, exp_st1;
  logic [FLOAT_MANT_SIZE_F`F-1:0] frac_st0, frac_st1;

  float_decoder #(
    .FSIZE  (FSIZE)
  ) float_decoder_inst (
    .bits   (bits_i),
    .sign   (sign_st0),
    .exp    (exp_st0),
    .frac   (frac_st0)
  );

  
  assign sign_st1 = sign_st0;
  assign exp_st1 = exp_st0;
  assign frac_st1 = frac_st0;

  assign fir_o = {sign_st1, exp_st1, frac_st1};

  
endmodule: float_to_fir

