package ppu_pkg;


localparam int unsigned OP_BITS = 4;

  typedef enum logic [OP_BITS-1:0] {
      FCVTSP8,FCVTSP160,FCVTSP161,FCVTP8S,FCVTP160S,FCVTP161S
  } operation_ppe;

endpackage