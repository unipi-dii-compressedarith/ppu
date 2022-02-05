`ifndef SVINCLUDES
`define SVINCLUDES

function [(N)-1:0] c2(input [(N)-1:0] a);
    c2 = ~a + 1'b1;
endfunction

function [N-1:0] abs(input [N-1:0] in);
    abs = in[N-1] == 0 ? in : c2(in);
endfunction

function [N-1:0] min(
        input [N-1:0] a, b
    );
    min = a <= b ? a : b;
endfunction

function [N-1:0] max(
        input [N-1:0] a, b
    );
    max = a >= b ? a : b;
endfunction

function is_negative(input [S:0] k);
    is_negative = k[S];
endfunction

function [N-1:0] shl (
        input [N-1:0] bits,
        input [N-1:0] rhs
    );
    shl = rhs[N-1] == 0 ? bits << rhs : bits >> c2(rhs);
endfunction


`endif