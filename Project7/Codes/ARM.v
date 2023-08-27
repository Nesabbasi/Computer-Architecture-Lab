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

module ARM(clk, rst, forward_en, SRAM_ADDR, SRAM_DQ, SRAM_UB_N, SRAM_LB_N, SRAM_WE_N, SRAM_CE_N, SRAM_OE_N);
    input clk, rst, forward_en;
    output SRAM_UB_N, SRAM_LB_N, SRAM_WE_N, SRAM_CE_N, SRAM_OE_N;
    output [17:0] SRAM_ADDR;
    inout [15:0] SRAM_DQ; 

    wire ready, hazard, freeze, branch_taken;
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
    wire IDreg_mem_read_out, IDreg_mem_write_out, IDreg_WB_en_out, IDreg_imm_out, IDreg_B_out, IDreg_S_out;
    wire [`REG_FILE_ADDRESS_LEN-1:0] IDreg_regFile_dst;
    wire [3:0] IDreg_execute_cmd_out, IDreg_status_reg_out;
    wire [`REG_FILE_ADDRESS_LEN-1:0] IDreg_regFile_src1, IDreg_regFile_src2;
    wire [`SHIFTER_OPERAND_WIDTH-1:0] IDreg_shifter_operand;
    wire [`SIGNED_IMM_WIDTH-1:0] IDreg_signed_immediate;
    wire [`WORD_WIDTH-1:0] IDreg_pc_out, IDreg_val_Rn, IDreg_val_Rm;
    

    //EXE Stage
    wire EXE_wb_en_out, EXE_mem_read_out, EXE_mem_write_out;
    wire [`WORD_WIDTH-1:0] EXE_alu_out, EXE_val_Rm_out;
    wire [`REG_FILE_ADDRESS_LEN-1:0] EXE_dst_out;

    //EXE Reg
    wire EXEreg_wb_en_out, EXEreg_mem_read_out, EXEreg_mem_write_out;
    wire [`WORD_WIDTH-1:0] EXEreg_alu_out, EXEreg_val_Rm_out;
    wire [`REG_FILE_ADDRESS_LEN-1:0] EXEreg_dst_out;
    
    //MEM Stage
    wire MEM_wb_en_out, MEM_mem_read_out;
    wire [`WORD_WIDTH-1:0] MEM_alu_out;
    wire [`REG_FILE_ADDRESS_LEN-1:0] MEM_dst_out;
    wire [`WORD_WIDTH-1:0] mem_out;

    //MEM Reg
    wire MEMreg_wb_en_out, MEMreg_mem_read_out;
    wire [`WORD_WIDTH-1:0] MEMreg_alu_out;
    wire [`REG_FILE_ADDRESS_LEN-1:0] MEMreg_dst_out;
    wire [`WORD_WIDTH-1:0] MEMreg_mem_out;


    //WB Stage
    wire WB_WB_en_out;
    wire [`WORD_WIDTH-1:0] WB_value;
    wire [`REG_FILE_ADDRESS_LEN-1:0] WB_dst_out;
    
    //Hazard Detector
    wire two_src;

    //Forwarding Unit
    wire [1 : 0] FWD_sel_src1, FWD_sel_src2;

    IF_Stage IF_stage(.clk(clk), .rst(rst), .freeze(hazard | freeze), .branch_taken(branch_taken), .branchAddr(branchAddr), .pc(IFStagePcOut),
                      .instruction(IFStageInstructionOut));

    IF_Stage_Reg IF_stage_reg(.clk(clk), .rst(rst), .freeze(hazard | freeze), .flush(branch_taken), .pcIn(IFStagePcOut), .instructionIn(IFStageInstructionOut),
                              .pcOut(IFRegPcOut), .instruction(IFRegInstructionOut));

    ID_Stage ID_stage(.clk(clk), .rst(rst), .freeze(hazard), .reg_file_enable(WB_WB_en_out),  .pc_in(IFRegPcOut), .instruction_in(IFRegInstructionOut),
                      .reg_file_result_WB(WB_value), .reg_file_dest_wb(WB_dst_out), .status_register(status_reg_out), .pcOut(ID_pc_out),
                      .val_Rn(ID_val_Rn), .val_Rm(ID_val_Rm), .signed_immediate(ID_signed_immediate), .shifter_operand(ID_shifter_operand), 
                      .reg_file_src1(ID_regFile_src1), .reg_file_src2(ID_regFile_src2), .reg_file_dst(ID_regFile_dst),
                      .execute_cmd_out(ID_execute_cmd_out), .mem_read_out(ID_mem_read_out), .mem_write_out(ID_mem_write_out),
                      .WB_en_out(ID_WB_en_out), .Imm_out(ID_imm_out), .B_out(ID_B_out), .status_update_out(ID_status_update_out));

    ID_Stage_Reg ID_stage_reg(.clk(clk), .rst(rst), .flush(branch_taken), .freeze(freeze), .mem_read_in(ID_mem_read_out), .mem_write_in(ID_mem_write_out),
                              .WB_Enable_in(ID_WB_en_out), .Imm_in(ID_imm_out), .B_in(ID_B_out), .status_update_in(ID_status_update_out), 
                              .reg_file_dst_in(ID_regFile_dst), .executeCommand_in(ID_execute_cmd_out), .status_register_in(status_reg_out),
                              .reg_file_src1_in(ID_regFile_src1), .reg_file_src2_in(ID_regFile_src2), .shifter_operand_in(ID_shifter_operand),
                              .signed_immediate_in(ID_signed_immediate), .pc_in(ID_pc_out), .val_Rn_in(ID_val_Rn), .val_Rm_in(ID_val_Rm),
                              .mem_read_out(IDreg_mem_read_out), .mem_write_out(IDreg_mem_write_out), .WB_Enable_out(IDreg_WB_en_out),
                              .Imm_out(IDreg_imm_out), .B_out(IDreg_B_out), .status_update_out(IDreg_S_out),
                              .reg_file_dst_out(IDreg_regFile_dst), .execute_cmd_out(IDreg_execute_cmd_out), .status_register_out(IDreg_status_reg_out),
                              .reg_file_src1_out(IDreg_regFile_src1), .reg_file_src2_out(IDreg_regFile_src2), .shifter_operand_out(IDreg_shifter_operand),
                              .signed_immediate_out(IDreg_signed_immediate), .pc_out(IDreg_pc_out), 
                              .val_Rn_out(IDreg_val_Rn), .val_Rm_out(IDreg_val_Rm));

    Exec_Stage exec_stage(.clk(clk), .rst(rst), .pc_in(IDreg_pc_out), .mem_read_in(IDreg_mem_read_out), .mem_write_in(IDreg_mem_write_out), .S(IDreg_S_out), .B(IDreg_B_out),
                          .WB_en_in(IDreg_WB_en_out), .execute_cmd_in(IDreg_execute_cmd_out), .immediate_in(IDreg_imm_out), .signed_immediate_24_in(IDreg_signed_immediate),
                          .shift_operand_in(IDreg_shifter_operand), .val_Rn_in(IDreg_val_Rn), .val_Rm_in(IDreg_val_Rm), .SR_in(IDreg_status_reg_out), .dst_in(IDreg_regFile_dst),
                          .alu_res_in_MEM(MEM_alu_out), .wb_value_WB(WB_value), .alu_mux_src_1_sel(FWD_sel_src1), .alu_mux_src_2_sel(FWD_sel_src2),
                          .alu_out(EXE_alu_out), .branch_address(branchAddr), .status_reg_out(status_reg_out), .branch_taken_out(branch_taken), .WB_en_out(EXE_wb_en_out), 
                          .mem_read_out(EXE_mem_read_out), .mem_write_out(EXE_mem_write_out), .dst_out(EXE_dst_out), .val_Rm_out(EXE_val_Rm_out));

    Exec_Stage_Reg Exec_stage_reg(.clk(clk), .rst(rst), .freeze(freeze), .dst_in(EXE_dst_out), .mem_read_in(EXE_mem_read_out), .mem_write_in(EXE_mem_write_out), .WB_en_in(EXE_wb_en_out),
                                  .val_Rm_in(EXE_val_Rm_out), .ALU_res_in(EXE_alu_out), .dst_out(EXEreg_dst_out), .ALU_res_out(EXEreg_alu_out), .val_Rm_out(EXEreg_val_Rm_out),
                                  .mem_read_out(EXEreg_mem_read_out), .mem_write_out(EXEreg_mem_write_out), .WB_en_out(EXEreg_wb_en_out));

    Mem_Stage Mem_stage(.clk(clk), .rst(rst), .dst(EXEreg_dst_out), .ALU_res(EXEreg_alu_out), .val_Rm(EXEreg_val_Rm_out), .mem_read(EXEreg_mem_read_out), .mem_write(EXEreg_mem_write_out),
                        .WB_en(EXEreg_wb_en_out), .dst_out(MEM_dst_out), .ALU_res_out(MEM_alu_out), .mem_out(mem_out), .mem_read_out(MEM_mem_read_out), .WB_en_out(MEM_wb_en_out),
                        .ready(ready), .SRAM_UB_N(SRAM_UB_N), .SRAM_LB_N(SRAM_LB_N), .SRAM_WE_N(SRAM_WE_N), .SRAM_CE_N(SRAM_CE_N), .SRAM_OE_N(SRAM_OE_N),
                         .SRAM_ADDR(SRAM_ADDR), .SRAM_DQ(SRAM_DQ));
    
    assign freeze = ~ready;

    Mem_Stage_Reg Mem_stage_reg(.clk(clk), .rst(rst), .freeze(freeze), .dst(MEM_dst_out), .ALU_res(MEM_alu_out), .mem_data(mem_out), .mem_read(MEM_mem_read_out), .WB_en(MEM_wb_en_out),
                                .dst_out(MEMreg_dst_out), .ALU_res_out(MEMreg_alu_out), .mem_data_out(MEMreg_mem_out), .mem_read_out(MEMreg_mem_read_out), .WB_en_out(MEMreg_wb_en_out));

    WB_Stage wb_stage(.clk(clk), .rst(rst), .dst(MEMreg_dst_out), .ALU_res(MEMreg_alu_out), .mem_data(MEMreg_mem_out), .mem_read(MEMreg_mem_read_out), .WB_en(MEMreg_wb_en_out),
                      .WB_dst(WB_dst_out), .WB_en_out(WB_WB_en_out), .WB_value(WB_value));

    assign two_src = ID_mem_write_out | ~ID_imm_out;
    Hazard_Detector hazard_detector(.src1(ID_regFile_src1), .src2(ID_regFile_src2), .exe_wb_dest(EXE_dst_out), .mem_wb_dest(MEM_dst_out), .two_src(two_src),  .exe_wb_enable(EXE_wb_en_out),
                                    .mem_wb_enable(MEM_wb_en_out), .forward_en(forward_en), .EXE_mem_read_en(IDreg_mem_read_out), .hazard(hazard));  

    Forwarding_Unit forwarding_unit(.forward_en(forward_en), .WB_wb_en(WB_WB_en_out), .MEM_wb_en(MEM_wb_en_out), .MEM_dst(MEM_dst_out), .WB_dst(WB_dst_out), .src1_in(IDreg_regFile_src1), 
                                    .src2_in(IDreg_regFile_src2), .sel_src1(FWD_sel_src1), .sel_src2(FWD_sel_src2));
endmodule