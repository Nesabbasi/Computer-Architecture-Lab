`timescale 1ns / 1ns

`define WORD_WIDTH 32
`define REG_FILE_ADDRESS_LEN 4
`define REG_FILE_SIZE 16
`define MEMORY_DATA_LEN 8
`define MEMORY_SIZE 2048
`define SIGNED_IMM_WIDTH 24
`define SHIFTER_OPERAND_WIDTH 12

`define INSTRUCTION_LEN         32
`define INSTRUCTION_MEM_SIZE    2048
`define DATA_MEM_SIZE 64

`define LSL_SHIFT 2'b00
`define LSR_SHIFT 2'b01
`define ASR_SHIFT 2'b10
`define ROR_SHIFT 2'b11

`define MODE_ARITHMETIC 2'b00
`define MODE_MEM 2'b01
`define MODE_BRANCH 2'b10

`define EX_MOV 4'b0001
`define EX_MVN 4'b1001
`define EX_ADD 4'b0010
`define EX_ADC 4'b0011
`define EX_SUB 4'b0100
`define EX_SBC 4'b0101
`define EX_AND 4'b0110
`define EX_ORR 4'b0111
`define EX_EOR 4'b1000
`define EX_CMP 4'b0100     ///1100
`define EX_TST 4'b0110     ///1110
`define EX_LDR 4'b0010     ///1010
`define EX_STR 4'b0010     ///1010

`define OP_MOV 4'b1101
`define OP_MVN 4'b1111
`define OP_ADD 4'b0100
`define OP_ADC 4'b0101
`define OP_SUB 4'b0010
`define OP_SBC 4'b0110
`define OP_AND 4'b0000
`define OP_ORR 4'b1100
`define OP_EOR 4'b0001
`define OP_CMP 4'b1010
`define OP_TST 4'b1000
`define OP_LDR 4'b0100
`define OP_STR 4'b0100
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