`ifdef N
parameter N = `N;
// `else
// parameter N = 16;
`endif



`ifdef ES
parameter ES = `ES;
`endif


`ifndef OP_SIZE
parameter OP_SIZE = 3;
/*
ADD,
SUB,
MUL,
DIV,
FLOAT2POSIT
POSIT2FLOAT
*/
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
parameter MANT_SIZE = N - 2;    // mant (mantissa) and frac (fraction) are 
                                // not the same thing. mant is a Fx<1,MANT_SIZE>. 
                                // frac is a Fx<0, MANT_SIZE-1>
parameter MS = MANT_SIZE;       // alias

parameter MAX_TE_DIFF = MS; // not really, but it works anyway.
parameter MTD = MAX_TE_DIFF; // alias


parameter RECIPROCATE_MANT_SIZE = 2 * MANT_SIZE;
parameter RMS = RECIPROCATE_MANT_SIZE; // alias

/****************************************/
parameter MANT_MUL_RESULT_SIZE = 2 * MS;
parameter MANT_ADD_RESULT_SIZE = MS + MTD + 1;
parameter MANT_SUB_RESULT_SIZE = MS + MTD;
parameter MANT_DIV_RESULT_SIZE = MS + RMS;
/****************************************/
parameter FRAC_FULL_SIZE = MANT_DIV_RESULT_SIZE - 2; // this is the largest among all the operation, most likely.
`endif


// PIF is posit intermediate format
`ifndef PIF_SIZE
parameter PIF_SIZE = 1 + TE_SIZE + MANT_SIZE; // sign size + total exponent size + mantissa size
`endif



parameter ZERO =    {`N{1'b0}};
parameter NAN =     {1'b1, {`N-1{1'b0}}};


parameter   ADD =               3'd0;
parameter   SUB =               3'd1;
parameter   MUL =               3'd2;
parameter   DIV =               3'd3;
parameter   FLOAT_TO_POSIT =    3'd4;

`define STRINGIFY(DEFINE) $sformatf("%0s", `"DEFINE`")

