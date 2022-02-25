module input_conditioning #(
        parameter N = 4
    )(
        input [N-1:0]       p1_in,
        input [N-1:0]       p2_in,
        input [OP_SIZE-1:0] op,
        output [N-1:0]      p1_out, 
        output [N-1:0]      p2_out
    );

    wire [N-1:0] _p1, _p2;
    assign _p1 = p1_in;
    assign _p2 = op == SUB ? c2(p2_in) : p2_in;

    wire op_is_add_or_sub;
    assign op_is_add_or_sub = (op == ADD || op == SUB);

    assign {p1_out, p2_out} = 
            (op_is_add_or_sub && abs(_p2) > abs(_p1)) ? 
            {_p2, _p1} : {_p1, _p2};

endmodule



// module input_conditioning #(
//         parameter N = 5
//     )(
//         input [OP_SIZE-1:0] op,
//         input sign1_in, 
//         input sign2_in,
//         input [TE_SIZE-1:0] te1_in,
//         input [TE_SIZE-1:0] te2_in,
//         input [MANT_SIZE-1:0] mant1_in,
//         input [MANT_SIZE-1:0] mant2_in,

//         output p2_larger_than_p1,
//         output sign1_out, 
//         output sign2_out,
//         output [TE_SIZE-1:0] te1_out,
//         output [TE_SIZE-1:0] te2_out,
//         output [MANT_SIZE-1:0] mant1_out,
//         output [MANT_SIZE-1:0] mant2_out
//     );

//     wire op_is_add_or_sub;
//     assign op_is_add_or_sub = (op == ADD || op == SUB);


//     assign p2_larger_than_p1 = 
//         $signed(te2_in) > $signed(te1_in) ? 1'b1 : 
//         ($signed(te2_in) == $signed(te1_in)) && (mant2_in > mant1_in) ? 1'b1 : 1'b0;

//     // swap if operation is addition or subtraction and p2 is larger than p1
//     assign {sign1_out, sign2_out} = 
//         op_is_add_or_sub && p2_larger_than_p1 ? {sign2_in, sign1_in} : {sign1_in, sign2_in};
//     assign {te1_out, te2_out} = 
//         op_is_add_or_sub && p2_larger_than_p1 ? {te2_in, te1_in} : {te1_in, te2_in};
//     assign {mant1_out, mant2_out} = 
//         op_is_add_or_sub && p2_larger_than_p1 ? {mant2_in, mant1_in} : {mant1_in, mant2_in};

// endmodule
