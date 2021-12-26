`ifdef N
parameter N = `N;
`else
$display("missing N");
`endif

`ifdef N
parameter ES = `ES;
`else
$display("missing ES");
`endif



parameter S = $clog2(N);

parameter DECODE_OUTPUT_SIZE = (
      1                 // sign 
    + 1                 // reg_s
    + ($clog2(N) + 1)   // reg_len
    + ($clog2(N) + 1)   // k
    + ES                // exp
    + N                 // mant
);

parameter ENCODE_INPUT_SIZE = (
      1                 // sign
    + ($clog2(N) + 1)   // reg_len
    + ($clog2(N) + 1)   // k
    + ES                // exp
    + N                 // mant
);
