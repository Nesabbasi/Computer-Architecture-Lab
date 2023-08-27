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

module ID_Stage (clk, rst, freeze, reg_file_enable,  pc_in, instruction_in, reg_file_result_WB, reg_file_dest_wb, status_register,
                                    pcOut, val_Rn, val_Rm, signed_immediate, shifter_operand, reg_file_src1,
                                    reg_file_src2, reg_file_dst, execute_cmd_out, mem_read_out, mem_write_out, WB_en_out, Imm_out, B_out, status_update_out);


    input clk, rst, freeze, reg_file_enable;
    input [`WORD_WIDTH-1:0] pc_in, instruction_in, reg_file_result_WB;
    input [3:0] reg_file_dest_wb, status_register;

    output [`WORD_WIDTH-1:0] pcOut, val_Rn, val_Rm;
    output [`SIGNED_IMM_WIDTH-1:0] signed_immediate;
	output [`SHIFTER_OPERAND_WIDTH-1:0] shifter_operand;
    output [`REG_FILE_ADDRESS_LEN-1:0] reg_file_src1, reg_file_src2, reg_file_dst, execute_cmd_out;
    output mem_read_out, mem_write_out, WB_en_out, Imm_out, B_out, status_update_out;

    wire [8:0] ctrl_unit_mux_in, ctrl_unit_mux_out;
    wire[3:0] executeCommand;
    wire mem_read, mem_write, WB_Enable, B, status_update, condition_state;
	wire ctrl_unit_mux_enable;
    wire [`WORD_WIDTH-1:0] val_Rn_temp, val_Rm_temp;
    Mux2To1 #(4) muxRegFile(.out(reg_file_src2),.in1(instruction_in[3:0]), .in2(instruction_in[15:12]), .sel(mem_write));
    Register_File regFile(.reg1(val_Rn_temp), .reg2(val_Rm_temp), .result_WB(reg_file_result_WB), .src1(reg_file_src1), .src2(reg_file_src2),
                         .dest_wb(reg_file_dest_wb), .writeBackEn(reg_file_enable), .rst(rst), .clk(clk));
    Mux2To1 #(9) muxCtrlUnit(.out(ctrl_unit_mux_out),.in1(ctrl_unit_mux_in), .in2(9'd0), .sel(ctrl_unit_mux_enable));
    Control_Unit ctrlUnit(.S(instruction_in[20]), .mode(instruction_in[27:26]), .op_code(instruction_in[24:21]), .executeCommand(executeCommand),
                          .mem_read(mem_read), .mem_write(mem_write), .WB_Enable(WB_Enable), .B(B), .status_update(status_update));
    Condition_Check condCheck(.cond(instruction_in[31:28]), .status_register(status_register), .condition(condition_state));

    wire isRn15, isRm15;
    assign isRn15 = &reg_file_src1;
    assign isRm15 = &reg_file_src2;
    Mux2To1 #(`WORD_WIDTH) muxRnVal(.out(val_Rn),.in1(val_Rn_temp), .in2(pc_in), .sel(isRn15));
    Mux2To1 #(`WORD_WIDTH) muxRmVal(.out(val_Rm),.in1(val_Rm_temp), .in2(pc_in), .sel(isRm15));

    assign pcOut = pc_in;
    assign ctrl_unit_mux_in = {status_update, B, executeCommand, mem_write, mem_read, WB_Enable};
    assign {status_update_out, B_out, execute_cmd_out, mem_write_out, mem_read_out, WB_en_out} = ctrl_unit_mux_out;
    
    assign ctrl_unit_mux_enable = (~condition_state) | freeze;

    assign shifter_operand = instruction_in[11:0];
	assign reg_file_dst = instruction_in[15:12];
	assign reg_file_src1 = instruction_in[19:16];
	assign signed_immediate = instruction_in[23:0];
	assign Imm_out = instruction_in[25];

endmodule