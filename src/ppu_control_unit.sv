module ppu_control_unit (
    input                      clk,
    input                      rst,
    input                      valid_i,
    input        [OP_SIZE-1:0] op,
    output                     valid_o,
    output logic               stall_o
);

    logic valid;


`ifdef TB_PPU_CONTROL_UNIT
    reg [(300)-1:0] state_reg = 'hz;
    localparam INIT = "INIT";
    localparam OP = "OP";
    localparam DIV_1 = "DIV_1";
    localparam DIV_2 = "DIV_2";
    localparam S1 = "S1";
    localparam S2 = "S2";
    localparam _TMP = "_TMP";
`elsif TB_PIPELINED
    reg [(300)-1:0] state_reg = 'hz;
    localparam INIT = "INIT";
    localparam OP = "OP";
    localparam DIV_1 = "DIV_1";
    localparam DIV_2 = "DIV_2";
    localparam S1 = "S1";
    localparam S2 = "S2";
    localparam _TMP = "_TMP";
`else
    reg [(4)-1:0] state_reg = INIT;
    localparam INIT = 0;
    localparam OP = 1;
    localparam DIV_1 = 2;
    localparam DIV_2 = 3;
    localparam S1 = 4;
    localparam S2 = 5;
    localparam _TMP = 6;
`endif


    wire [OP_SIZE-1:0] __op = op;

    always_ff @(posedge clk) begin
        if (rst) begin
            stall_o <= 0;
            valid <= 0;

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
                    if (valid_i && (__op === ADD || __op === MUL || __op === SUB)) begin
                        state_reg <= S1;
                    end else if (valid_i && __op === DIV) begin
                        state_reg <= DIV_2;
                    end else begin  /* !valid_i */
                        state_reg <= _TMP;
                    end
                end
                DIV_2: begin
                    if (valid_i && (__op === ADD || __op === MUL || __op === SUB)) begin
                        state_reg <= S1;
                    end else if (valid_i && __op === DIV) begin
                        state_reg <= DIV_2;
                    end else begin  /* !valid_i */
                        state_reg <= _TMP;
                    end
                end
                S1: begin
                    if (valid_i && (__op !== DIV)) begin
                        state_reg <= S2;
                    end else begin
                        state_reg <= OP;
                    end
                end
                S2: begin
                    state_reg <= OP;
                end
                _TMP: begin
                    state_reg <= INIT;
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
            S2: begin
                stall_o = 0;
                valid   = 1;  //& valid_i;
            end
            _TMP: begin
                stall_o = 0;
                valid   = 1;  //& valid_i;
            end
            default: begin
                stall_o = 0;
                valid   = 0;
            end
        endcase
    end


    logic valid_in_st0, valid_in_st1, valid_in_st2, valid_in_st3;
    always_ff @(posedge clk) begin
        if (rst) begin
            valid_in_st0 <= 0;
            valid_in_st1 <= 0;
            valid_in_st2 <= 0;
            valid_in_st3 <= 0;
        end else begin
            valid_in_st0 <= valid;
            valid_in_st1 <= valid_in_st0;
            valid_in_st2 <= valid_in_st1;
            valid_in_st3 <= valid_in_st2;
        end
    end

    assign valid_o = valid_in_st0;


    logic [OP_SIZE-1:0] op_st0;
    always_ff @(posedge clk) begin
        if (rst) begin
            op_st0 <= 0;
        end else begin
            op_st0 <= op;
        end
    end

endmodule
