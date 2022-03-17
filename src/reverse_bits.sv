/*
iverilog reverse_bits.sv
*/
module reverse_bits #(
    parameter SIZE = 8
) (
    input  wire [N-1:0] bits,
    output wire [N-1:0] reversed_bits
);

    localparam N = SIZE;

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : _gen_loop
            assign reversed_bits[i] = bits[N-1-i];
        end
    endgenerate

endmodule
