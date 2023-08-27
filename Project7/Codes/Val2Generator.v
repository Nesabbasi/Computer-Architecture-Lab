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

module Val2Generator(val_Rm, shift_operand, immediate, is_mem_cmd, val2_out);
    input [`WORD_WIDTH-1:0] val_Rm;
    input [`SHIFTER_OPERAND_WIDTH-1:0] shift_operand;
    input immediate, is_mem_cmd;
    output reg [`WORD_WIDTH-1:0] val2_out;

    reg [2 * (`WORD_WIDTH) - 1 : 0] tmp;
    integer i;
    always @(val_Rm, shift_operand, immediate, is_mem_cmd) begin
        val2_out = `WORD_WIDTH'b0;
        tmp = 0;
        if (is_mem_cmd == 1'b0) begin

            if (immediate == 1'b1) begin
                val2_out = {24'b0 ,shift_operand[7 : 0]};
                for (i = 0; i < 2 * shift_operand[11:8]; i = i + 1) begin
                    val2_out = {val2_out[0], val2_out[31:1]};
                end

            end 
            else if(immediate == 1'b0 && shift_operand[4] == 0) begin
                case(shift_operand[6:5])
                    `LSL_SHIFT : begin
                        val2_out = val_Rm << shift_operand[11 : 7];
                    end
                    `LSR_SHIFT : begin
                        val2_out = val_Rm >> shift_operand[11 : 7];
                    end
                    `ASR_SHIFT : begin
                        val2_out = $signed(val_Rm) >>> shift_operand[11 : 7];
                    end
                    `ROR_SHIFT : begin
                       val2_out = val_Rm;
                        for (i = 0; i < shift_operand[11:7]; i = i + 1) begin
                            val2_out = {val2_out[0], val2_out[31:1]};
                        end
                    end
                endcase
            end
        end 
        else //is mem_command
        begin
            val2_out = { {20{shift_operand[11]}} , shift_operand}; 
        end

    end
endmodule