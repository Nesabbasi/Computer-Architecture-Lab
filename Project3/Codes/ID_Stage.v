`include "defines.v"
`include "Register_File.v"
`include "Control_Unit.v"
`include "Condition_Check.v"
`include "Mux2To1.v"

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
    Mux2To1 #(4) muxRegFile(.out(reg_file_src2),.in1(instruction_in[3:0]), .in2(instruction_in[15:12]), .sel(mem_write));
    Register_File regFile(.reg1(val_Rn), .reg2(val_Rm), .result_WB(reg_file_result_WB), .src1(reg_file_src1), .src2(reg_file_src2),
                         .dest_wb(reg_file_dest_wb), .writeBackEn(reg_file_enable), .rst(rst), .clk(clk));
    Mux2To1 #(9) muxCtrlUnit(.out(ctrl_unit_mux_out),.in1(ctrl_unit_mux_in), .in2(9'd0), .sel(ctrl_unit_mux_enable));
    Control_Unit ctrlUnit(.S(instruction_in[20]), .mode(instruction_in[27:26]), .op_code(instruction_in[24:21]), .executeCommand(executeCommand),
                          .mem_read(mem_read), .mem_write(mem_write), .WB_Enable(WB_Enable), .B(B), .status_update(status_update));
    Condition_Check condCheck(.cond(instruction_in[31:28]), .status_register(status_register), .condition(condition_state));

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