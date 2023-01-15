module posit_to_float #(
  parameter N = `N,
  parameter ES = `ES,
  parameter FSIZE = `F
)(
  input [N-1:0] posit,
  output [FSIZE-1:0] float_bits
);

  parameter FLOAT_EXP_SIZE = FLOAT_EXP_SIZE_F`F;
  parameter FLOAT_MANT_SIZE = FLOAT_MANT_SIZE_F`F;

  ppu_pkg::fir_t fir;

  posit_to_fir #(
    .N(N),
    .ES(ES)
  ) posit_to_fir_inst (
    .p_cond(posit),
    .fir(fir)
  );

  fir_to_float #(
    .N(N),
    .ES(ES),
    .FSIZE(FSIZE)
  ) fir_to_float_inst (
    .fir(fir),
    .float(float_bits)
  );

endmodule: posit_to_float


`ifdef TB_POSIT_TO_FLOAT
module tb_posit_to_float;

  parameter N = `N;
  parameter ES = `ES;
  parameter FSIZE = `F;
  parameter FLOAT_EXP_SIZE = FLOAT_EXP_SIZE_F`F;
  parameter FLOAT_MANT_SIZE = FLOAT_MANT_SIZE_F`F;



  reg [N-1:0] posit;
  wire [FSIZE-1:0] float_bits;

  reg [FSIZE-1:0] float_bits_expected;

  reg [200:0] ascii_x, ascii_exp, ascii_frac, posit_expected_ascii;


  posit_to_float #(
    .N(N),
    .ES(ES),
    .FSIZE(FSIZE)
  ) posit_to_float_inst (
    .posit(posit),
    .float_bits(float_bits)
  );

  reg diff;
  always_comb @(*) begin
    diff = float_bits == float_bits_expected? 0 : 1'bX;
  end


  initial begin
  $dumpfile({"tb_posit_P",`STRINGIFY(`N),"E",`STRINGIFY(`ES),"_to_float_F",`STRINGIFY(`F),".vcd"});
  $dumpvars(0, tb_posit_to_float);                        


  // 8,0
  if (N == 8 && ES == 0 && FSIZE == 16) begin
    `include "../test_vectors/tv_posit_to_float_P8E0_F16.sv"
  end
  if (N == 8 && ES == 0 && FSIZE == 32) begin
    `include "../test_vectors/tv_posit_to_float_P8E0_F32.sv"
  end
  if (N == 8 && ES == 0 && FSIZE == 64) begin
    `include "../test_vectors/tv_posit_to_float_P8E0_F32.sv"
  end

  // 8,1
  if (N == 8 && ES == 1 && FSIZE == 16) begin
    `include "../test_vectors/tv_posit_to_float_P8E1_F16.sv"
  end
  if (N == 8 && ES == 1 && FSIZE == 32) begin
    `include "../test_vectors/tv_posit_to_float_P8E1_F32.sv"
  end
  if (N == 8 && ES == 1 && FSIZE == 64) begin
    `include "../test_vectors/tv_posit_to_float_P8E1_F32.sv"
  end

  // 16,0
  if (N == 16 && ES == 0 && FSIZE == 16) begin
    `include "../test_vectors/tv_posit_to_float_P16E0_F16.sv"
  end
  if (N == 16 && ES == 0 && FSIZE == 32) begin
    `include "../test_vectors/tv_posit_to_float_P16E0_F32.sv"
  end
  if (N == 16 && ES == 0 && FSIZE == 64) begin
    `include "../test_vectors/tv_posit_to_float_P16E0_F32.sv"
  end

  // 16,1
  if (N == 16 && ES == 1 && FSIZE == 16) begin
    `include "../test_vectors/tv_posit_to_float_P16E1_F16.sv"
  end
  if (N == 16 && ES == 1 && FSIZE == 32) begin
    `include "../test_vectors/tv_posit_to_float_P16E1_F32.sv"
  end
  if (N == 16 && ES == 1 && FSIZE == 64) begin
    `include "../test_vectors/tv_posit_to_float_P16E1_F32.sv"
  end

  // 16,2
  if (N == 16 && ES == 2 && FSIZE == 16) begin
    `include "../test_vectors/tv_posit_to_float_P16E2_F16.sv"
  end
  if (N == 16 && ES == 2 && FSIZE == 32) begin
    `include "../test_vectors/tv_posit_to_float_P16E2_F32.sv"
  end
  if (N == 16 && ES == 2 && FSIZE == 64) begin
    `include "../test_vectors/tv_posit_to_float_P16E2_F32.sv"
  end

  // 32,2
  if (N == 32 && ES == 2 && FSIZE == 16) begin
    `include "../test_vectors/tv_posit_to_float_P32E2_F16.sv"
  end
  if (N == 32 && ES == 2 && FSIZE == 32) begin
    `include "../test_vectors/tv_posit_to_float_P32E2_F32.sv"
  end
  if (N == 32 && ES == 2 && FSIZE == 64) begin
    `include "../test_vectors/tv_posit_to_float_P32E2_F32.sv"
  end

end


endmodule: tb_posit_to_float
`endif
