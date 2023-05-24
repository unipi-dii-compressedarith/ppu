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
  input  logic[(FX_B)-1:0]                          fixed_i, // c2
  output logic[(1+FIR_TE_SIZE+FIR_FRAC_SIZE)-1:0]   fir_o
);

  logic                           fir_sign;
  logic signed [FIR_TE_SIZE-1:0]  fir_te;
  logic [FIR_FRAC_SIZE-1:0]       fir_frac;


  logic [$clog2(FX_B-1)-1:0] lzc_fixed; // FX_B-1 because sign is excluded
  logic lzc_valid;

  
  logic fixed_i_sign;
  assign fixed_i_sign = fixed_i[(FX_B)-1];

  logic [(FX_B)-1:0] fixed_i_abs;
  assign fixed_i_abs = (fixed_i_sign == 1'b0) ? fixed_i : (~fixed_i + 1'b1);
  
  lzc #(
    .NUM_BITS   (FX_B)
  ) lzc_inst (
    .bits_i     (fixed_i_abs),
    .lzc_o      (lzc_fixed),
    .valid_o    (lzc_valid)
  );


  assign fir_sign = fixed_i_sign;
  assign fir_te = FX_M - lzc_fixed;

  localparam MANT_MAX_LEN = N - 1 - 2; // -1: sign lenght, -2: regime min length

  

  logic [(FX_B)-1:0] fixed_i_abs_corrected;
  assign fixed_i_abs_corrected = (fir_te >= 0) ? (fixed_i_abs >> fir_te) : (fixed_i_abs << (-fir_te));

  logic [(FX_B-FX_M-1)-1:0] fixed_i_abs_corrected_frac_only;
  assign fixed_i_abs_corrected_frac_only = fixed_i_abs_corrected; // MS bits automatically cut off by the size


  localparam FX_N = FX_B        // fixed total length
                    - FX_M      // fixed integer part length
                    - 1;        // sign length

  generate
    if (FIR_FRAC_SIZE <= FX_N)  assign fir_frac = (fixed_i_abs_corrected[(1+FX_N)-1:0] >> (FX_N - FIR_FRAC_SIZE));
    else                        assign fir_frac = (fixed_i_abs_corrected[(1+FX_N)-1:0] << (FIR_FRAC_SIZE - FX_N));
  endgenerate

  assign fir_o = {fir_sign, fir_te, fir_frac};

endmodule: fixed_to_fir
