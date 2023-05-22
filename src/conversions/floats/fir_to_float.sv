`ifdef FLOAT_TO_POSIT
module fir_to_float 
  import ppu_pkg::*;
#(
  parameter N = -1,
  parameter ES = -1,
  parameter FSIZE = -1
)(
  input                   clk_i,
  input                   rst_i,
  input ppu_pkg::fir_t    fir_i,
  output [FSIZE-1:0]      float_o
);

  parameter FLOAT_EXP_SIZE = FLOAT_EXP_SIZE_F`F;
  parameter FLOAT_MANT_SIZE = FLOAT_MANT_SIZE_F`F;

  ppu_pkg::fir_t fir_st0, fir_st1;
  assign fir_st0 = fir_i;


  `ifdef PIPELINE_STAGE
    always_ff @(posedge clk) begin
      if (rst) begin
        fir_st1 <= 0;
      end else begin
        fir_st1 <= fir_st0;
      end
    end
  `else
    assign fir_st1 = fir_st0;
  `endif

  wire posit_sign;
  exponent_t posit_te; // wire signed [TE_BITS-1:0] posit_te;
  wire [MANT_SIZE-1:0] posit_frac;

  assign {posit_sign, posit_te, posit_frac} = fir_st1;


  wire float_sign;
  wire signed [FLOAT_EXP_SIZE-1:0] float_exp;
  wire [FLOAT_MANT_SIZE-1:0] float_frac;

  assign float_sign = posit_sign;
  
  sign_extend #(
    .POSIT_TOTAL_EXPONENT_SIZE(TE_BITS),
    .FLOAT_EXPONENT_SIZE(FLOAT_EXP_SIZE)
  ) sign_extend_inst (
    .posit_total_exponent(posit_te),
    .float_exponent(float_exp)
  );      


  assign float_frac = posit_frac << (FLOAT_MANT_SIZE - MANT_SIZE + 1);

  float_encoder #(
    .FSIZE(FSIZE)
  ) float_encoder_inst (
    .sign(float_sign),
    .exp(float_exp),
    .frac(float_frac),
    .bits(float_o)
  );


endmodule: fir_to_float
`endif
