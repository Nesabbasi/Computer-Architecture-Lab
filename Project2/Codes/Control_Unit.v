`include "defines.v"
module Control_Unit(S, mode, op_code, executeCommand, mem_read, mem_write, WB_Enable, B, status_update);
    input S;
    input [1:0] mode;
    input [3:0] op_code;
    output reg [3:0] executeCommand;
    output reg  mem_read, mem_write, WB_Enable, B;
    output status_update;

    always @(*) begin
        {mem_read, mem_write, WB_Enable, B} = 4'd0;
        case (mode)
            `MODE_BRANCH: begin
                B = 1'b1;
            end

            `MODE_MEM: begin
                case (S)
                    0: begin
                        executeCommand = `EX_STR;
                        mem_write = 1'b1;
                    end
                    1: begin
                        executeCommand = `EX_LDR;
                        mem_read = 1'b1;
                        WB_Enable = 1'b1;
                    end
                endcase
            end

            `MODE_ARITHMETIC: begin
                case (op_code)
                    `OP_MOV: begin
                        executeCommand = `EX_MOV;
                        WB_Enable = 1'b1;
                    end

                    `OP_MVN: begin
                        executeCommand = `EX_MVN;
                        WB_Enable = 1'b1;
                    end

                    `OP_ADD: begin
                        executeCommand = `EX_ADD;
                        WB_Enable = 1'b1;
                    end

                    `OP_ADC: begin
                        executeCommand = `EX_ADC;
                        WB_Enable = 1'b1;
                    end

                    `OP_SUB: begin
                        executeCommand = `EX_SUB;
                        WB_Enable = 1'b1;
                    end

                    `OP_SBC: begin
                        executeCommand = `EX_SBC;
                        WB_Enable = 1'b1;
                    end
                    `OP_AND: begin
                        executeCommand = `EX_AND;
                        WB_Enable = 1'b1;
                    end

                    `OP_ORR: begin
                        executeCommand = `EX_ORR;
                        WB_Enable = 1'b1;
                    end

                    `OP_EOR: begin
                        executeCommand = `EX_EOR;
                        WB_Enable = 1'b1;
                    end

                    `OP_CMP: begin
                        executeCommand = `EX_CMP;
                        WB_Enable = 1'b0;
                    end

                    `OP_TST: begin
                        executeCommand = `EX_TST;
                        WB_Enable = 1'b0;
                    end
                endcase
            end
        endcase
    end

    assign status_update = S;
endmodule