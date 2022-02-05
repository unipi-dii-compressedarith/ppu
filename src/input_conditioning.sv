module input_conditioning #(
        parameter N = `N
    )(
        input [N-1:0] p1_in,
        input [N-1:0] p2_in,
        input [OP_SIZE-1:0] op,
        output [N-1:0] p1_out, 
        output [N-1:0] p2_out
    );

    function [N-1:0] c2(input [N-1:0] a);
        c2 = ~a + 1'b1;
    endfunction

    function [N-1:0] abs(input [N-1:0] in);
        abs = in[N-1] == 0 ? in : c2(in);
    endfunction

    wire [N-1:0] _p1, _p2;
    assign _p1 = p1_in;
    assign _p2 = op == SUB ? c2(p2_in) : p2_in;

    wire op_is_add_or_sub;
    assign op_is_add_or_sub = (op == ADD || op == SUB);

    assign {p1_out, p2_out} = 
            (op_is_add_or_sub && abs(_p2) > abs(_p1)) ? 
            {_p2, _p1} : {_p1, _p2};



endmodule