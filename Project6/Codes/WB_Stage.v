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

module WB_Stage(clk, rst, dst, ALU_res, mem_data, mem_read, WB_en, WB_dst, WB_en_out, WB_value);
    input clk, rst;
    input [`REG_FILE_ADDRESS_LEN-1:0] dst;
    input [`WORD_WIDTH-1:0] ALU_res;
    input [`WORD_WIDTH-1:0] mem_data;
    input mem_read, WB_en;

    output [`REG_FILE_ADDRESS_LEN-1:0] WB_dst;
    output WB_en_out;
    output [`WORD_WIDTH-1:0] WB_value;

    assign WB_dst = dst;
    assign WB_en_out = WB_en;

    Mux2To1 #(`WORD_WIDTH) MUX_2_to_1_Reg_File (.out(WB_value), .in1(ALU_res), .in2(mem_data), .sel(mem_read));

endmodule