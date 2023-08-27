`include "IF_Stage.v"
`include "IF_Stage_Reg.v"
`include "ID_Stage.v"
`include "ID_Stage_Reg.v"
`include "Exec_Stage.v"
`include "Exec_Stage_Reg.v"
`include "Mem_Stage.v"
`include "Mem_Stage_Reg.v"
`include "WB_Stage.v"
`include "defines.v"
module ARM(clk, rst, out);
    input clk, rst;
    output [31:0] out;
    wire freeze, branch_taken;
    //IF Stage
    wire  [`WORD_WIDTH-1:0] branchAddr, IFStagePcOut, IFRegPcOut, IFStageInstructionOut, IFRegInstructionOut;

    //ID Stage
    wire  [`WORD_WIDTH-1:0] ID_pc_out, ID_val_Rn, ID_val_Rm;
    wire [`SIGNED_IMM_WIDTH-1:0] ID_signed_immediate;
    wire [`SHIFTER_OPERAND_WIDTH-1:0] ID_shifter_operand;
    wire [`REG_FILE_ADDRESS_LEN-1:0] ID_regFile_src1, ID_regFile_src2, ID_regFile_dst;
    wire [3:0] ID_execute_cmd_out, status_reg_out;
    wire ID_mem_read_out, ID_mem_write_out, ID_WB_en_out, ID_imm_out, ID_B_out, ID_status_update_out;

    //ID Reg
    wire IDreg_mem_read_out, IDreg_mem_write_out, IDreg_WB_en_out, IDreg_imm_out, IDreg_B_out, IDreg_status_update_out;
    wire [`REG_FILE_ADDRESS_LEN-1:0] IDreg_regFile_dst;
    wire [3:0] IDreg_execute_cmd_out, IDreg_status_out;
    wire [`REG_FILE_ADDRESS_LEN-1:0] IDreg_regFile_src1, IDreg_regFile_src2;
    wire [`SHIFTER_OPERAND_WIDTH-1:0] IDreg_shifter_operand;
    wire [`SIGNED_IMM_WIDTH-1:0] IDreg_signed_immediate;
    wire  [`WORD_WIDTH-1:0] IDreg_pc_out, IDreg_val_Rn, IDreg_val_Rm;
    //////////
    wire [31:0]  execOut, exMemRegOut, memOut, memWbRegOut, IFIDregOut;

    //EXE Stage
    wire EXE_B_out;
    
    //WB Stage
    wire WB_WB_en_out;
    wire [`WORD_WIDTH-1:0] WB_Value;
    wire [`REG_FILE_ADDRESS_LEN-1:0] WB_dst_out;
    

    IF_Stage IF_stage(.clk(clk), .rst(rst), .freeze(freeze), .branch_taken(branch_taken), .branchAddr(branchAddr), .pc(IFStagePcOut),
                      .instruction(IFStageInstructionOut));
    IF_Stage_Reg IF_stage_reg(.clk(clk), .rst(rst), .freeze(freeze), .flush(branch_taken), .pcIn(IFStagePcOut), .instructionIn(IFStageInstructionOut),
                              .pcOut(IFRegPcOut), .instruction(IFRegInstructionOut));

    ID_Stage ID_stage(.clk(clk), .rst(rst), .freeze(1'b0), .reg_file_enable(/*WB_WB_en_out*/1'b0),  .pc_in(IFRegPcOut), .instruction_in(IFStageInstructionOut),
                      .reg_file_result_WB(/*WB_value*/32'd0), .reg_file_dest_wb(/*WB_dst_out*/ 4'd0), .status_register(/*status_reg_out*/4'd0), .pcOut(ID_pc_out),
                      .val_Rn(ID_val_Rn), .val_Rm(ID_val_Rm), .signed_immediate(ID_signed_immediate), .shifter_operand(ID_shifter_operand), 
                      .reg_file_src1(ID_regFile_src1), .reg_file_src2(ID_regFile_src2), .reg_file_dst(ID_regFile_dst),
                      .execute_cmd_out(ID_execute_cmd_out), .mem_read_out(ID_mem_read_out), .mem_write_out(ID_mem_write_out),
                      .WB_en_out(ID_WB_en_out), .Imm_out(ID_imm_out), .B_out(ID_B_out), .status_update_out(ID_status_update_out));

    ID_Stage_Reg ID_stage_reg(.clk(clk), .rst(rst), .flush(EXE_B_out), .mem_read_in(ID_mem_read_out), .mem_write_in(ID_mem_write_out),
                              .WB_Enable_in(ID_WB_en_out), .Imm_in(ID_imm_out), .B_in(ID_B_out), .status_update_in(ID_status_update_out), 
                              .reg_file_dst_in(ID_regFile_dst), .executeCommand_in(ID_execute_cmd_out), .status_register_in(/*status_reg_out*/4'd0),
                              .reg_file_src1_in(ID_regFile_src1), .reg_file_src2_in(ID_regFile_src2), .shifter_operand_in(ID_shifter_operand),
                              .signed_immediate_in(ID_signed_immediate), .pc_in(ID_pc_out), .val_Rn_in(ID_val_Rn), .val_Rm_in(ID_val_Rm),
                              .mem_read_out(IDreg_mem_read_out), .mem_write_out(IDreg_mem_write_out), .WB_Enable_out(IDreg_WB_en_out),
                              .Imm_out(IDreg_imm_out), .B_out(IDreg_B_out), .status_update_out(IDreg_status_update_out),
                              .reg_file_dst_out(IDreg_regFile_dst), .execute_cmd_out(IDreg_execute_cmd_out), .status_register_out(IDreg_status_out),
                              .reg_file_src1_out(IDreg_regFile_src1), .reg_file_src2_out(IDreg_regFile_src2), .shifter_operand_out(IDreg_shifter_operand),
                              .signed_immediate_out(IDreg_signed_immediate), .pc_out(IDreg_pc_out), 
                              .val_Rn_out(IDreg_val_Rn), .val_Rm_out(IDreg_val_Rm));
    Exec_Stage Exec_stage(.clk(clk), .rst(rst), .in(IDreg_pc_out), .out(execOut));
    Exec_Stage_Reg Exec_stage_reg(.clk(clk), .rst(rst), .in(execOut), .out(exMemRegOut));
    Mem_Stage Mem_stage(.clk(clk), .rst(rst), .in(exMemRegOut), .out(memOut));
    Mem_Stage_Reg Mem_stage_reg(.clk(clk), .rst(rst), .in(memOut), .out(memWbRegOut));
    WB_Stage WB_stage(.clk(clk), .rst(rst), .in(memWbRegOut), .out(out));
endmodule