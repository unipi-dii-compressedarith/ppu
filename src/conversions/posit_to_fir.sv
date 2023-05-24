module posit_to_fir 
  import ppu_pkg::*;
#(
  parameter N  = -1,
  parameter ES = -1
) (
  input posit_t p_cond_i,
  output fir_t fir_o
);

  posit_decoder #(
    .N        (N),
    .ES       (ES)
  ) posit_decoder_inst (
    .bits_i   (p_cond_i),
    .fir_o    (fir_o)
  );

endmodule: posit_to_fir
