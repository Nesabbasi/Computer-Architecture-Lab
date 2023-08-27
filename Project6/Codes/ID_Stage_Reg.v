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

module ID_Stage_Reg #(parameter N = 32)(clk, rst, flush, freeze, mem_read_in, mem_write_in, WB_Enable_in, Imm_in, B_in, status_update_in, 
                                        reg_file_dst_in, executeCommand_in, status_register_in, reg_file_src1_in, reg_file_src2_in, 
                                        shifter_operand_in, signed_immediate_in, pc_in, val_Rn_in, val_Rm_in, mem_read_out, 
                                        mem_write_out, WB_Enable_out, Imm_out, B_out, status_update_out, reg_file_dst_out, execute_cmd_out,
                                        status_register_out, reg_file_src1_out, reg_file_src2_out, shifter_operand_out, signed_immediate_out,
                                        pc_out, val_Rn_out, val_Rm_out);

    input clk, rst, flush, freeze, mem_read_in, mem_write_in, WB_Enable_in, Imm_in, B_in, status_update_in;
    input [3:0] reg_file_dst_in, executeCommand_in, status_register_in, reg_file_src1_in, reg_file_src2_in;
    input [`SHIFTER_OPERAND_WIDTH-1:0] shifter_operand_in;
    input [`SIGNED_IMM_WIDTH-1:0] signed_immediate_in;
    input [`WORD_WIDTH-1:0] pc_in, val_Rn_in, val_Rm_in;

    output reg mem_read_out, mem_write_out, WB_Enable_out, Imm_out, B_out, status_update_out;
    output reg [3:0] reg_file_dst_out, execute_cmd_out, status_register_out, reg_file_src1_out, reg_file_src2_out;
    output reg [`SHIFTER_OPERAND_WIDTH-1:0] shifter_operand_out;
    output reg [`SIGNED_IMM_WIDTH-1:0] signed_immediate_out;
    output reg [`WORD_WIDTH-1:0] pc_out, val_Rn_out, val_Rm_out;



   always @(posedge clk, posedge rst) begin
    if (rst) 
        begin
            pc_out <= 0;
            reg_file_dst_out <= 0;
            val_Rn_out <= 0;
            val_Rm_out <=0;
            signed_immediate_out <= 0;
            shifter_operand_out <= 0;
            execute_cmd_out <= 0;
            status_register_out <= 0;
            mem_read_out <= 0;
            mem_write_out <= 0;
            WB_Enable_out <= 0;
            Imm_out <= 0;
            B_out <= 0;
            status_update_out <= 0;
            reg_file_src1_out <= 0;
            reg_file_src2_out <= 0;
        end
    else if (freeze) begin
    end
    else if (flush) 
        begin
            pc_out <= 0;
            reg_file_dst_out <= 0;
            val_Rn_out <= 0;
            val_Rm_out <=0;
            signed_immediate_out <= 0;
            shifter_operand_out <= 0;
            execute_cmd_out <= 0;
            status_register_out <= 0;
            mem_read_out <= 0;
            mem_write_out <= 0;
            WB_Enable_out <= 0;
            Imm_out <= 0;
            B_out <= 0;
            status_update_out <= 0;
            reg_file_src1_out <= 0;
            reg_file_src2_out <= 0;
        end
    else 
        begin
            pc_out <= pc_in;
            reg_file_dst_out <= reg_file_dst_in;
            val_Rn_out <= val_Rn_in;
            val_Rm_out <= val_Rm_in;
            signed_immediate_out <= signed_immediate_in;
            shifter_operand_out <= shifter_operand_in;
            execute_cmd_out <= executeCommand_in;
            status_register_out <= status_register_in;
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            WB_Enable_out <= WB_Enable_in;
            Imm_out <= Imm_in;
            B_out <= B_in;
            status_update_out <= status_update_in;
            reg_file_src1_out <= reg_file_src1_in;
            reg_file_src2_out <= reg_file_src2_in;
        end
  end
endmodule