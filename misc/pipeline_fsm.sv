/*
[see `pipeline_fsm.pdf` in this folder]

iverilog -g2012 -DTB_PIPELINE_FSM pipeline_fsm.sv && ./a.out
*/


`ifndef OP_SIZE
parameter OP_SIZE = 3;
`endif
parameter ADD = 3'd0;
parameter SUB = 3'd1;
parameter MUL = 3'd2;
parameter DIV = 3'd3;
parameter FLOAT_TO_POSIT = 3'd4;
parameter POSIT_TO_FLOAT = 3'd5;



module pipeline_fsm (
    input                      clk,
    input                      rst,
    input                      valid_i,
    input        [OP_SIZE-1:0] op,
    output                     valid_o,
    output logic               stall_o
);

    logic valid;


`ifdef TB_PIPELINE_FSM
    reg [(300)-1:0] state_reg = 'hz;
    localparam INIT = "INIT";
    localparam OP = "OP";
    localparam DIV_1 = "DIV_1";
    localparam DIV_2 = "DIV_2";
    localparam S1 = "S1";
`else
    reg [(4)-1:0] state_reg;
    localparam INIT = 0;
    localparam OP = 1;
    localparam DIV_1 = 2;
    localparam DIV_2 = 3;
    localparam S1 = 4;
`endif


    wire [OP_SIZE-1:0] __op = op;

    always_ff @(posedge clk) begin
        if (rst) begin
            state_reg <= INIT;
        end else begin
            case (state_reg)
                INIT: begin
                    if (valid_i && (__op === ADD || __op === MUL || __op === SUB)) begin
                        state_reg <= OP;
                    end else if (valid_i && __op === DIV) begin
                        state_reg <= DIV_1;
                    end else begin  /* !valid_i */
                        state_reg <= INIT;
                    end
                end
                OP: begin
                    if (valid_i && (__op === ADD || __op === MUL || __op === SUB)) begin
                        state_reg <= OP;
                    end else if (valid_i && __op === DIV) begin
                        state_reg <= DIV_1;
                    end else begin  /* !valid_i */
                        state_reg <= INIT;
                    end
                end
                DIV_1: begin
                    if (valid_i && __op === DIV) begin
                        state_reg <= DIV_2;
                    end else begin  /* !valid_i */
                        state_reg <= S1;
                    end
                end
                DIV_2: begin
                    if (valid_i && __op === DIV) begin
                        state_reg <= DIV_2;
                    end else begin  /* !valid_i */
                        state_reg <= S1;
                    end
                end
                S1: begin
                    if (valid_i && (__op === ADD || __op === SUB || __op === MUL)) begin
                        state_reg <= OP;
                    end else if (valid_i && __op === DIV) begin
                        state_reg <= DIV_1;
                    end else begin  /* !valid_i */
                        state_reg <= INIT;
                    end
                end
                default: begin
                    state_reg <= state_reg;
                end
            endcase
        end
    end



    always @(*) begin
        case (state_reg)
            INIT: begin
                stall_o = 0;
                valid   = 0;
            end
            OP: begin
                stall_o = 0;
                valid   = 1;  //& valid_i;
            end
            DIV_1: begin
                stall_o = 0;
                valid   = 0;
            end
            DIV_2: begin
                stall_o = 0;
                valid   = 1;  //& valid_i;
            end
            S1: begin
                stall_o = 1;
                valid   = 1;  //& valid_i;
            end
            default: begin
                stall_o = 0;
                valid   = 0;
            end
        endcase
    end


    logic valid_in_st0, valid_in_st1, valid_in_st2;
    always_ff @(posedge clk) begin
        if (rst) begin
            valid_in_st0 <= 0;
            valid_in_st1 <= 0;
            valid_in_st2 <= 0;
        end else begin
            valid_in_st0 <= valid;
            valid_in_st1 <= valid_in_st0;
            valid_in_st2 <= valid_in_st1;
        end
    end

    assign valid_o = valid_in_st2;

endmodule



`ifdef TB_PIPELINE_FSM
module tb_pipeline_fsm;

    reg                clk;
    reg                rst;
    reg                ppu_valid_in;
    reg                valid_i;
    reg  [OP_SIZE-1:0] ppu_op;
    reg  [OP_SIZE-1:0] op;
    wire               valid_o;
    wire               stall_o;



    pipeline_fsm tb_pipeline_fsm (
        .clk(clk),
        .rst(rst),
        .valid_i(ppu_valid_in),
        .op(ppu_op),
        .valid_o(valid_o),
        .stall_o(stall_o)
    );



    always begin
        clk = ~clk;
        #5;
    end

    initial begin
        $dumpfile("tb_pipeline_fsm.vcd");
        $dumpvars(0, tb_pipeline_fsm);
        clk = 0;
    end


    localparam DEL = 10;
    initial begin
        rst = 1;
        ppu_op = 'hz;
        ppu_valid_in = 0;
        #12;
        rst = 0;
        #5;



        ppu_valid_in = 1;
        ppu_op = ADD;
        #10;

        ppu_valid_in = 1;
        ppu_op = DIV;
        #10;

        ppu_valid_in = 0;
        ppu_op = 'hz;
        #10;


        ppu_valid_in = 1;
        ppu_op = SUB;
        #10;

        ppu_valid_in = 1;
        ppu_op = DIV;
        #12;

        ppu_valid_in = 0;
        ppu_op = 'hz;
        #10;


        ppu_valid_in = 1;
        ppu_op = MUL;
        #9;

        ppu_valid_in = 1;
        ppu_op = DIV;
        #10;


        // ppu_valid_in = 1;
        // ppu_op = MUL;
        // #10;


        // ppu_valid_in = 1;
        // ppu_op = SUB;
        // #10;


        // ppu_valid_in = 1;
        // ppu_op = DIV;
        // #10;


        // ppu_valid_in = 1;
        // ppu_op = DIV;
        // #10;

        // ppu_valid_in = 1;
        // ppu_op = ADD;
        // #10;




        ppu_op = 'bz;
        ppu_valid_in = 0;

        #100;
        $finish;
    end



endmodule
`endif
