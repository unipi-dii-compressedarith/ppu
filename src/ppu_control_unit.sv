/*
also checkout the ~prototype~ at `$ROOT/misc/pipeline_fsm.sv`
*/

module ppu_control_unit (
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
    localparam ANY_OP = "ANY_OP";
`elsif TB_PIPELINED
    reg [(300)-1:0] state_reg = 'hz;
    localparam INIT = "INIT";
    localparam ANY_OP = "ANY_OP";
`else
    reg [(1)-1:0] state_reg = INIT;
    localparam INIT = 0;
    localparam ANY_OP = 1;
`endif


    wire [OP_SIZE-1:0] __op = op;

    always_ff @(posedge clk) begin
        if (rst) begin
            state_reg <= INIT;
        end else begin
            case (state_reg)
                INIT: begin
                    if (valid_i) begin
                        state_reg <= ANY_OP;
                    end else begin  /* !valid_i */
                        state_reg <= INIT;
                    end
                end
                ANY_OP: begin
                    if (valid_i) begin
                        state_reg <= ANY_OP;
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
            ANY_OP: begin
                stall_o = 0;
                valid   = 1;
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

    assign valid_o = valid_in_st1;

endmodule
