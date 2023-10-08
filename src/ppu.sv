/// Posit Processing Unit (PPU)
module ppu
  import ppu_pkg::*;
#(
  parameter WORD = `WORD,
  `ifdef FLOAT_TO_POSIT
    parameter FSIZE = `F,
  `endif
  parameter N = `N,
  parameter ES = `ES
) (
  input logic                           clk_i,
  input logic                           rst_i,
  input logic                           in_valid_i,
  input ppu_pkg::word_t                 operand1_i,
  input ppu_pkg::word_t                 operand2_i,
  input ppu_pkg::word_t                 operand3_i,
  input ppu_pkg::operation_e            op_i,
  output ppu_pkg::word_t result_o,
  output logic                          out_valid_o,
  output ppu_pkg::accumulator_t         fixed_o
);

  logic stall;
  
  ppu_pkg::fir_t posit_fir;
  ppu_pkg::posit_t p1, p2, p3, posit;

  assign p1 = operand1_i[N-1:0];
  assign p2 = operand2_i[N-1:0];
  assign p3 = operand3_i[N-1:0];


  ////////////////////////////////////////////////////////////
  /// float_fir, float_to_fir's side
  typedef struct packed {
    logic                           sign;
    logic [FLOAT_EXP_SIZE_F`F-1:0]  total_exponent;
    logic [FLOAT_MANT_SIZE_F`F-1:0] frac;
  } float_fir_float_to_fir_t;

  /// float_fir, ppu_core_ops' side
  typedef struct packed {
    logic                           sign;
    exponent_t                      total_exponent;
    logic [FRAC_FULL_SIZE-1:0]      frac;
  } float_fir_ppu_core_ops_t;
  ////////////////////////////////////////////////////////////

`ifdef FLOAT_TO_POSIT

  /// definition
  float_fir_float_to_fir_t float_fir_float_to_fir_o;
  float_fir_ppu_core_ops_t float_fir_ppu_core_ops_i;

  /// assignment
  assign float_fir_ppu_core_ops_i.sign            = float_fir_float_to_fir_o.sign;
  assign float_fir_ppu_core_ops_i.total_exponent  = float_fir_float_to_fir_o.total_exponent;
  assign float_fir_ppu_core_ops_i.frac            = {>>{float_fir_float_to_fir_o.frac}};

  // assign float_fir_ppu_core_ops_i = {>>{float_fir_float_to_fir_o.sign, float_fir_float_to_fir_o.total_exponent, float_fir_float_to_fir_o.frac}};


    /*   //no 
  //TODO fix streaming operation?
  logic [FRAC_FULL_SIZE-1:0] float_fir_frac;
  assign float_fir_frac = {>>{float_fir_float_to_fir_o.frac}};
  assign float_fir_ppu_core_ops_i.frac = {1'b1, float_fir_frac >> 1};
    */



  float_to_fir #(
    .FSIZE    (FSIZE)
  ) float_to_fir_inst (
    .clk_i    (clk_i),
    .rst_i    (rst_i),
    .bits_i   (operand1_i),
    .fir_o    (float_fir_float_to_fir_o)
  );

`endif


  ppu_core_ops #(
    .N            (N),
    .ES           (ES)
  ) ppu_core_ops_inst (
    .clk_i        (clk_i),
    .rst_i        (rst_i),
    .p1_i         (p1),
    .p2_i         (p2),
    .p3_i         (p3),
    .op_i         (op_i),
    .op_o         (),
    .stall_i      (stall),
  `ifdef FLOAT_TO_POSIT
    .float_fir_i  (float_fir_ppu_core_ops_i),
    .posit_fir_o  (posit_fir),
  `endif
    .pout_o       (posit),
    .fixed_o      (fixed_o)
  );



  

`ifdef POSIT_TO_FLOAT
  word_t float_out;

  fir_to_float #(
    .N            (N),
    .ES           (ES),
    .FSIZE        (FSIZE)
  ) fir_to_float_inst (
    .clk_i        (clk_i),
    .rst_i        (rst_i),
    .fir_i        (posit_fir),
    .float_o      (float_out)
  );

  assign result_o = (op_i == P2F) ? float_out : posit;
`else
  assign result_o = posit;
`endif

  
  
  
  ppu_control_unit #(
  ) ppu_control_unit_inst (
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .valid_i    (in_valid_i),
    .op_i       (op_i),
    .valid_o    (out_valid_o),
    .stall_o    (stall)
  );


endmodule: ppu
