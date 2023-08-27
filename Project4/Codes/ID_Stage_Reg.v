`include "defines.v"
module ID_Stage_Reg #(parameter N = 32)(clk, rst, flush, mem_read_in, mem_write_in, WB_Enable_in, Imm_in, B_in, status_update_in, 
                                        reg_file_dst_in, executeCommand_in, status_register_in, reg_file_src1_in, reg_file_src2_in, 
                                        shifter_operand_in, signed_immediate_in, pc_in, val_Rn_in, val_Rm_in, mem_read_out, 
                                        mem_write_out, WB_Enable_out, Imm_out, B_out, status_update_out, reg_file_dst_out, execute_cmd_out,
                                        status_register_out, reg_file_src1_out, reg_file_src2_out, shifter_operand_out, signed_immediate_out,
                                        pc_out, val_Rn_out, val_Rm_out);

    input clk, rst, flush, mem_read_in, mem_write_in, WB_Enable_in, Imm_in, B_in, status_update_in;
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