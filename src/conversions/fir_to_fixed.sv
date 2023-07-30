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
  parameter FX_B = -1
)(
  input   logic[(1+FIR_TE_SIZE+FIR_FRAC_SIZE)-1:0]    fir_i,
  output  logic[(FX_B)-1:0]                           fixed_o
);

  generate
    if ($bits(fir_i) >= $bits(fixed_o)) begin
      $error("$bits(fir_i) must be larger than $bits(fixed_o)");
    end
  endgenerate

  logic                           fir_sign;
  logic signed [FIR_TE_SIZE-1:0]  fir_te;
  logic [FIR_FRAC_SIZE-1:0]       fir_frac;
  assign {fir_sign, fir_te, fir_frac} = fir_i;


  logic[(FX_B)-1:0] fixed_tmp;
  
/*
  logic                   fixed_sign;
  logic [FX_M-1:0]        fixed_integer;
  logic [(FX_B-FX_M)-1:0] fixed_fraction;
  
  
  assign fixed_integer = fixed_tmp >> fir_te;
  assign fixed_fraction = fixed_tmp[(FX_B-FX_M)-1:0];
  assign fixed_sign = fir_sign;

  assign fixed_o = {fixed_sign, fixed_integer, fixed_fraction};
*/

  localparam MANT_MAX_LEN = N - 1 - 2; // -1: sign lenght, -2: regime min length

  assign fixed_tmp = fir_frac << (FX_B - FX_M - (MANT_MAX_LEN+1));

  logic fir_te_sign;
  assign fir_te_sign = fir_te >= 0;

  logic [(FX_B-1)-1:0] fixed_signless;
  assign fixed_signless = (fir_te >= 0) ? (fixed_tmp << fir_te) : (fixed_tmp >> (-fir_te));

  /// With correct sign
  assign fixed_o = fir_sign === 1'b0 ? fixed_signless : (~fixed_signless + 1'b1);

endmodule: fir_to_fixed
