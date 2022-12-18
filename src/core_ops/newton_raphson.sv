module newton_raphson 
  import ppu_pkg::MS;
#(
  parameter N = `N
)(
  input                   clk_i,
  input                   rst_i,
  input   [(MS)-1:0]      num_i,
  input   [(3*MS-4)-1:0]  x0_i,
  output  [(2*MS)-1:0]    x1_o
);
  
  /*

  num_i                     :   Fx<1, MS>
  x0_i                      :   Fx<1, 3MS - 4>

  num_i * x0_i              :   Fx<2, 4MS - 4>      -> Fx<2, 2MS> (downshifted by ((4MS-4) - (2MS) = 2MS - 4)

  2                         :   Fx<2, 2MS>

  2 - num_i * x0_i          :   Fx<2, 2MS>

  x0_2n                     :   Fx<1, 2MS>          -> x0_i downshifted by ((3MS - 3) - (2MS) = MS - 3)

  x0_2n * (2 - num_i * x0_i):   Fx<3, 4MS>          -> downshifted by ((4MS) - (2MS) - 2 = 2MS).
                                                                                      └── due to being:   000.101000111011101001110 vs      (what you have)
                                                                                                            0.10100011110                   (what you want)

  */


  wire [(4*MS-3)-1:0] _num_times_x0;
  assign _num_times_x0 = (num_i * x0_i) >> (2*MS - 4);
  
  
  logic [(2*MS)-1:0] num_times_x0_st0, num_times_x0_st1;
  assign num_times_x0_st0 = _num_times_x0;


  // generated with `scripts/gen_fixed_point_values.py`
  wire [(2*MS)-1:0] fx_2 = ppu_pkg::fx_2___N`N;

  wire [(2*MS)-1:0] two_minus_num_x0;
  assign two_minus_num_x0 = fx_2 - num_times_x0_st1;


  logic [(2*MS)-1:0] x0_on_2n_bits_st0, x0_on_2n_bits_st1;
  assign x0_on_2n_bits_st0 = x0_i >> (MS - 4);

  wire [(4*MS)-1:0] _x1;
  assign _x1 = x0_on_2n_bits_st1 * two_minus_num_x0;

  // assign x1_o = _x1[(4*MS-1)-:MS];
  assign x1_o = _x1 >> (2*MS - 2);


  ///// ! implement `FF macro later on
`ifdef PIPELINE_STAGE
  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      num_times_x0_st1 <= 0;
      x0_on_2n_bits_st1 <= 0;
    end else begin
      num_times_x0_st1 <= num_times_x0_st0;
      x0_on_2n_bits_st1 <= x0_on_2n_bits_st0;
    end
  end
`else
  assign num_times_x0_st1 = num_times_x0_st0;
  assign x0_on_2n_bits_st1 = x0_on_2n_bits_st0;
`endif

endmodule: newton_raphson
