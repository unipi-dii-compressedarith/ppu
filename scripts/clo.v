module clo #(
        parameter N = 8,
        parameter S = $clog2(N)  
    )(
        input [N-1:0] bits,
        output [S-1:0] run_length
    );

    wire [S-1:0] _tmp_out [0:N];

    genvar i;
    generate
        for (i=0; i<N; i=i+1) begin: _gen_for
            mux_base #(
                .DATA_WIDTH (S)
            ) mux_base_ist (
                .a          (_tmp_out[i]),
                .b          (i),
                .sel        (bits[N-1-i]),
                .out        (_tmp_out[i+1])
            );
        end
    endgenerate

    assign run_length = _tmp_out[N];
    assign _tmp_out[0] = bits[N-1];
endmodule

module mux_base #(
        parameter DATA_WIDTH = 8
    )(
        input  [DATA_WIDTH-1:0] a,
        input  [DATA_WIDTH-1:0] b,
        input                   sel,
        output [DATA_WIDTH-1:0] out
    );
    assign out = sel == 0 ? a : b;
endmodule


////////////////////////////////////////////////////////////////

module LOD_N #(
        parameter N = 64,
        parameter S = $clog2(N)
    )(
        input   [N-1:0] in,
        output  [S-1:0] out
    );
    wire vld;
    LOD #(.N(N)) l1 (in, out, vld);
endmodule

module LOD #(
        parameter N = 8,
        parameter S = $clog2(N)
    )(
        input   [N-1:0] in,
        output  [S-1:0] out,
        output          vld
    );

    generate
        if (N == 2) begin
            assign vld = |in;
            assign out = ~in[1] & in[0];
        end else if (N & (N-1)) begin
            //LOD #(1<<S) LOD ({1<<S {1'b0}} | in,out,vld);
            LOD #(
                .N      (1<<S)
            ) LOD (
                .in({in, {((1<<S) - N) {1'b0}}}),
                .out(out),
                .vld(vld));
        end else begin
            wire [S-2:0] out_l, out_h;
            wire out_vl, out_vh;
            
            LOD #(
                .N      (N >> 1)
            ) l (
                .in     (in[(N>>1)-1:0]), 
                .out    (out_l),
                .vld    (out_vl));
            
            LOD #(
                .N      (N >> 1)
            ) h (
                .in     (in[N-1 : N>>1]),
                .out    (out_h),
                .vld    (out_vh));

            assign vld = out_vl | out_vh;
            assign out = out_vh ? {1'b0, out_h} : {out_vl, out_l};
        end
    endgenerate
endmodule

/////////////////
module highest_set #(
	parameter SIZE = 8,
	parameter VAL = 1,
	parameter OUTW = $clog2(SIZE)
)(
	input logic[SIZE-1:0] bits,
	output wire [OUTW-1:0] index
);

	wire [OUTW-1:0]out_stage[0:SIZE];
	assign out_stage[0] = ~0; // desired default output if no bits set

	generate genvar i;
		for (i=0; i<SIZE; i=i+1) begin: _gen
    		assign out_stage[i+1] = (bits[i] == VAL) ? i : out_stage[i];
    	end
	endgenerate

	assign index = out_stage[SIZE];

endmodule
///////////////


module tb;

    parameter N = 4;
    parameter S = $clog2(N);

    reg [N-1:0] bits;
    wire [S-1:0] run_length_pacogen, run_length_mine, run_length_federicos;

    reg diff1, diff2;

    LOD_N #(
        .N(N),
        .S(S)
    ) lod_n_inst(
        .in(~bits), // pacogen counts the zeros
        .out(run_length_pacogen)
    );

    clo #(
        .N(N),
        .S(S)
    ) clo_inst(
        .bits(bits),
        .run_length(run_length_mine)
    );

    highest_set #(
        .SIZE(N),
        .VAL(1) // search first val
    ) highest_set_inst (
        .bits(~bits),
        .index(run_length_federicos)
    );

    always @(*) begin
        diff1 = run_length_mine == run_length_pacogen ? 0 : 1'bx;
        diff2 = N-run_length_federicos == run_length_pacogen ? 0 : 1'bx;
    end

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
    
            bits = 4'b1110;

        #10 bits = 4'b1100;
        #10 bits = 4'b1000;
        #10 bits = 4'b0000;
        #10 bits = 4'b0110;
        #10 bits = 4'b0001;
        #10 bits = 4'b0010;

                // bits = 8'b11110011;
        // #10;    bits = 8'b00010010;
        // #10;    bits = 8'b01010010;
        // #10;    bits = 8'b00000000;
        // #10;    bits = 8'b00000001;
        // #10;    bits = 8'b10010011;
        // #10;    bits = 8'b01110010;


        #10;
    end

endmodule
