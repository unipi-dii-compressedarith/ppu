/*
iverilog -g2012 -DTB_MEALY_FSM mealy_fsm.sv && ./a.out
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

module mealy_fsm (
    input                      clk,
    input                      rst,
    input                      valid_i,
    input        [OP_SIZE-1:0] op,
    output                     valid_o,
    output logic               stall_o,
    output logic               new_div_op_o
);


`ifdef TB_MEALY_FSM
    reg [(300)-1:0] state_reg, state_next;
    localparam INIT = "INIT";
    localparam OP = "OP";
    localparam DIV_OP = "DIV_OP";
`else
    reg [(4)-1:0] state_reg, state_next;
    localparam INIT = 0;
    localparam OP = 1;
    localparam DIV_OP = 2;
`endif


    always_ff @(posedge clk) begin
        if (rst) begin
            state_reg <= INIT;
        end else begin
            state_reg <= state_next;
        end
    end


    always @(*) begin
        state_next = state_reg;
        stall_o = 0;
        new_div_op_o = 0;

        case (state_reg)
            INIT: begin
                case (valid_i)
                    0: state_next = INIT;
                    1: begin
                        if (op == DIV) begin
                            state_next   = DIV_OP;
                            new_div_op_o = 1;
                        end else state_next = OP;
                    end
                endcase
            end
            OP: begin
                case (valid_i)
                    0: state_next = INIT;
                    1: begin
                        if (op == DIV) begin
                            state_next   = DIV_OP;
                            new_div_op_o = 1;
                        end else state_next = OP;
                    end
                endcase
            end
            DIV_OP: begin
                case (valid_i)
                    0: state_next = INIT;
                    1: begin
                        if (op == DIV) begin
                            state_next   = DIV_OP;
                            new_div_op_o = 1;
                        end else begin
                            state_next = OP;
                            stall_o = 1;
                        end
                    end
                endcase
            end
            default: begin
            end
        endcase
    end


    logic valid_in_st0, valid_in_st1, valid_in_st2, valid_in_st3, valid_in_st4;
    always_ff @(posedge clk) begin
        if (rst) begin
            valid_in_st0 <= 0;
            valid_in_st1 <= 0;
            valid_in_st2 <= 0;
            valid_in_st3 <= 0;
            // valid_in_st4 <= 0;
        end else begin
            valid_in_st0 <= stall_o ? valid_in_st0 : valid_i;
            valid_in_st1 <= valid_in_st0;
            valid_in_st2 <= valid_in_st1;
            valid_in_st3 <= valid_in_st2;
            valid_in_st4 <= valid_in_st3;
        end
    end

    assign valid_o = op_st4 !== DIV ? valid_in_st3 : valid_in_st4;


    logic [OP_SIZE-1:0] op_st0, op_st1, op_st2, op_st3, op_st4;
    always_ff @(posedge clk) begin
        if (rst) begin
            op_st0 <= 0;
            op_st1 <= 0;
            op_st2 <= 0;
            op_st3 <= 0;
            op_st4 <= 0;
        end else begin
            op_st0 <= op;
            op_st1 <= op_st0;
            op_st2 <= op_st1;
            op_st3 <= op_st2;
            op_st4 <= op_st3;
        end
    end

endmodule



`ifdef TB_MEALY_FSM
module tb_mealy_fsm;


    reg                clk;
    reg                rst;
    reg                valid_i;
    reg  [OP_SIZE-1:0] op;
    wire               valid_o;
    wire               stall_o;



    mealy_fsm mealy_fsm_inst (
        .clk(clk),
        .rst(rst),
        .valid_i(valid_i),
        .op(op),
        .valid_o(valid_o),
        .stall_o(stall_o)
    );



    always begin
        clk = ~clk;
        #5;
    end

    initial begin
        $dumpfile("tb_mealy_fsm.vcd");
        $dumpvars(0, tb_mealy_fsm);
        clk = 0;
    end


    localparam DEL = 10;
    initial begin
        rst = 1;
        op = 0;
        valid_i = 0;
        #12;
        rst = 0;
        #5;


        // valid_i = 1;
        // op = ADD;
        // #14;

        // valid_i = 1;
        // op = SUB;
        // #10;

        valid_i = 1;
        op = DIV;
        #10;

        // valid_i = 1;
        // op = DIV;
        // #10;

        // valid_i = 1;
        // op = ADD;
        // #10;

        // valid_i = 1;
        // op = SUB;
        // #10;

        op = 'bz;
        valid_i = 0;

        #100;
        $finish;
    end



endmodule
`endif
