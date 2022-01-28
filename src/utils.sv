// `ifdef N
// `define N `N
// `else
// `define N (16)
// `endif

// `ifdef ES
// `define ES (`ES)
// `else
// `define ES 1
// `endif

// `define S ($clog2(N))


// // `define DECODE_OUTPUT_SIZE (
// //       1                 // sign 
// //     + 1                 // reg_s
// //     + ($clog2(N) + 1)   // reg_len
// //     + ($clog2(N) + 1)   // k
// //     + ES                // exp
// //     + N                 // mant
// // )
// `define DECODE_OUTPUT_SIZE (1 + 1 + ($clog2(N) + 1) + ($clog2(N) + 1) + ES + N)



// // `define ENCODE_INPUT_SIZE (
// //       1                 // sign
// //     + ($clog2(N) + 1)   // reg_len
// //     + ($clog2(N) + 1)   // k
// //     + ES                // exp
// //     + N                 // mant
// // )
// `define ENCODE_INPUT_SIZE (1 + ($clog2(N) + 1) + ($clog2(N) + 1) + ES + N)



/////////////////////////////////////////////

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

`ifndef S
parameter S = $clog2(N);
`endif

`ifndef TE_SIZE
parameter TE_SIZE = (ES + 1) + (S + 1);
`endif

`ifndef REG_LEN_SIZE
parameter REG_LEN_SIZE = S + 1;
`endif

`ifndef K_SIZE
parameter K_SIZE = S + 1;
`endif

`ifndef FRAC_SIZE
parameter FRAC_SIZE = N - 1;
`endif

`ifndef MANT_SIZE
parameter MANT_SIZE = N;
`endif


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

