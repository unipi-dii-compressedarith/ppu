module input_conditioning #(
        parameter N = 4
    )(
        input [N-1:0]       p1_in,
        input [N-1:0]       p2_in,
        input [OP_SIZE-1:0] op,
        output [N-1:0]      p1_out, 
        output [N-1:0]      p2_out,

        output is_special_or_trivial,
        output [N-1:0] pout_special_or_trivial
    );

    wire [N-1:0] _p1, _p2;
    assign _p1 = p1_in;
    assign _p2 = op == SUB ? c2(p2_in) : p2_in;

    wire op_is_add_or_sub;
    assign op_is_add_or_sub = (op == ADD || op == SUB);

    assign {p1_out, p2_out} = 
            (op_is_add_or_sub && abs(_p2) > abs(_p1)) ? 
            {_p2, _p1} : {_p1, _p2};
    

    handle_special_or_trivial #(
        .N(N)
    ) handle_special_or_trivial_inst (
        .op(op),
        .p1_in(p1_in),
        .p2_in(p2_in),
        .pout(pout_special_or_trivial)
    );

    assign is_special_or_trivial = 
           p1_in == ZERO 
        || p1_in == NAN 
        || p2_in == ZERO 
        || p2_in == NAN
        || (op == SUB && p1_in == p2_in)
        || (op == ADD && p1_in == c2(p2_in));
        

endmodule
