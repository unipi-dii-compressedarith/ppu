/*
iverilog -g2012 -DTB_FSM fsm.sv && ./a.out
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

/*********************************************/

module fsm (
    input                    clk,
    input                    rst,     // reset 
    input                    en,      // enable
    input      [OP_SIZE-1:0] op,
    output reg               valid_o  // output valid
);


`ifdef TB_FSM
    reg [(300)-1:0] state = S_NONE;
    localparam S_NONE = "S_NONE";
    localparam S_ADD0 = "S_ADD0";
    localparam S_ADD1 = "S_ADD1";
    localparam S_MUL0 = "S_MUL0";
    localparam S_MUL1 = "S_MUL1";
    localparam S_DIV0 = "S_DIV0";
    localparam S_DIV1 = "S_DIV1";
    localparam S_DIV2 = "S_DIV2";
`else
    reg [(4)-1:0] state = S_NONE;
    localparam S_NONE = 0;
    localparam S_ADD0 = 1;
    localparam S_ADD1 = 2;
    localparam S_MUL0 = 3;
    localparam S_MUL1 = 4;
    localparam S_DIV0 = 5;
    localparam S_DIV1 = 6;
    localparam S_DIV2 = 7;

`endif

    always_ff @(posedge clk) begin
        case (en)
            0: state <= state;
            1: begin
                case (op)
                    ADD: begin
                        case (state)
                            S_ADD0: state <= S_ADD1;
                            S_MUL0: state <= S_MUL1;
                            S_DIV0: state <= S_DIV1;
                            S_DIV1: state <= S_DIV2;
                            default: state <= S_ADD0;
                        endcase
                    end
                    SUB: begin
                        case (state)
                            S_ADD0: state <= S_ADD1;
                            S_MUL0: state <= S_MUL1;
                            S_DIV0: state <= S_DIV1;
                            S_DIV1: state <= S_DIV2;
                            default: state <= S_ADD0;
                        endcase
                    end
                    MUL: begin
                        case (state)
                            S_ADD0: state <= S_ADD1;
                            S_MUL0: state <= S_MUL1;
                            S_DIV0: state <= S_DIV1;
                            S_DIV1: state <= S_DIV2;
                            default: state <= S_MUL0;
                        endcase
                    end
                    DIV: begin
                        case (state)
                            S_ADD0: state <= S_ADD1;
                            S_MUL0: state <= S_MUL1;
                            S_DIV0: state <= S_DIV1;
                            S_DIV1: state <= S_DIV2;
                            default: state <= S_DIV0;
                        endcase
                    end
                    default: begin
                        case (state)
                            S_ADD0: state <= S_ADD1;
                            S_MUL0: state <= S_MUL1;
                            S_DIV0: state <= S_DIV1;
                            S_DIV1: state <= S_DIV2;
                            default: state <= S_NONE;
                        endcase
                    end
                endcase
            end
        endcase
    end


    always_ff @(posedge clk) begin
        case (en)
            1'b0: valid_o <= 0;
            default: begin
                case (state)
                    S_ADD1: valid_o <= 1;
                    S_MUL1: valid_o <= 1;
                    S_DIV2: valid_o <= 1;
                    default: valid_o <= 0;
                endcase
            end
        endcase
    end

endmodule

`ifdef TB_FSM
module tb_fsm;
    reg                clk;
    reg                rst;
    reg                en;
    reg  [OP_SIZE-1:0] op;
    wire               valid_o;



    fsm #() fsm_inst (
        .clk(clk),
        .rst(rst),
        .en(en),
        .op(op),
        .valid_o(valid_o)
    );

    always begin
        clk = ~clk;
        #5;
    end

    initial begin
        $dumpfile("tb_fsm.vcd");
        $dumpvars(0, tb_fsm);
        clk = 0;
    end


    localparam DEL = 10;
    initial begin
        en = 1;
        #DEL;
        
        op = ADD;
        #DEL;

        
        #100000;
        $finish;
    end


endmodule
`endif