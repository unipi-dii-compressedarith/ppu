`ifdef N
parameter N = `N;
// `else
// parameter N = 16;
`endif

`ifdef ES
parameter ES = `ES;
// `else
// parameter ES = 1;
`endif

`ifndef OP_SIZE
parameter OP_SIZE = 2;
`endif


`ifndef S
parameter S = $clog2(N);
`endif

`ifndef TE_SIZE
parameter TE_SIZE = (ES + 1) + (S + 1);
`endif

`ifndef REG_LEN_SIZE
parameter REG_LEN_SIZE = S + 1;
`endif

`ifndef MANT_LEN_SIZE
parameter MANT_LEN_SIZE = S + 1;
`endif

`ifndef K_SIZE
parameter K_SIZE = S + 2; // prev. S + 1 (leads to bug when te too large)
`endif

`ifndef FRAC_SIZE
parameter FRAC_SIZE = N - 1;
`endif

`ifndef MANT_SIZE
parameter MANT_SIZE = N;
`endif



parameter ADD = 2'b00;
parameter SUB = 2'b01;
parameter MUL = 2'b10;
parameter DIV = 2'b11;

// `ifndef DECODE_OUTPUT_SIZE
// parameter DECODE_OUTPUT_SIZE = (
//       1                 // sign 
//     + 1                 // reg_s
//     + ($clog2(N) + 1)   // reg_len
//     + ($clog2(N) + 1)   // k
//     + ES                // exp
//     + MANT_SIZE         // mant
// );
// `endif

// `ifndef ENCODE_INPUT_SIZE
// parameter ENCODE_INPUT_SIZE = (
//       1                 // sign
//     + ($clog2(N) + 1)   // reg_len
//     + ($clog2(N) + 1)   // k
//     + ES                // exp
//     + MANT_SIZE         // mant
// );
// `endif

