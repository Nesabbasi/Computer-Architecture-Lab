`include "defines.v"
`include "ALU.v"
`include "Mux3To1.v"
`include "Val2Generator.v"
`include "Adder.v"
`include "Status_Register.v"
module Exec_Stage(clk, rst, pc_in, mem_read_in, mem_write_in, S, B, WB_en_in, execute_cmd_in, immediate_in, signed_immediate_24_in, shift_operand_in, val_Rn_in, 
                 val_Rm_in, SR_in, dst_in, alu_out, branch_address, status_reg_out, branch_taken_out, WB_en_out, mem_read_out, mem_write_out, dst_out, val_Rm_out);

	input clk, rst;
	input [`WORD_WIDTH-1: 0] pc_in;
	input mem_read_in, mem_write_in, S, B, WB_en_in;
	input [3:0] execute_cmd_in;
	input immediate_in;
	input [`SIGNED_IMM_WIDTH-1:0] signed_immediate_24_in;
	input [`SHIFTER_OPERAND_WIDTH - 1 : 0] shift_operand_in;
	input [`WORD_WIDTH - 1: 0] val_Rn_in, val_Rm_in;
	input [3:0] SR_in; 
	input [`REG_FILE_ADDRESS_LEN-1:0] dst_in;

	output [`WORD_WIDTH - 1 : 0] alu_out;
	output [`WORD_WIDTH - 1 : 0] branch_address;
	output [3:0] status_reg_out;
	output branch_taken_out, WB_en_out, mem_read_out, mem_write_out;
	output [`REG_FILE_ADDRESS_LEN-1:0] dst_out;
	output [`WORD_WIDTH - 1 : 0] val_Rm_out;
	

	wire [3:0] status_bits;
	wire [`WORD_WIDTH - 1 : 0] val2out;
	
	ALU alu(.val1(val_Rn_in), .val2(val2out), .cin(SR_in[2]), .EX_command(execute_cmd_in), .ALU_out(alu_out), .SR(status_bits));

	wire is_mem_cmd;
	assign is_mem_cmd = mem_read_in | mem_write_in;

	assign dst_out = dst_in;
	assign branch_taken_out = B;
	assign mem_read_out = mem_read_in;
	assign mem_write_out = mem_write_in;
	assign WB_en_out = WB_en_in;

	Status_Register status_ref(.clk(clk), .rst(rst), .ld(S), .in(status_bits), .out(status_reg_out));

	assign val_Rm_out = val_Rm_in; 
    Val2Generator v2g(.val_Rm(val_Rm_in), .shift_operand(shift_operand_in), .immediate(immediate_in), .is_mem_cmd(is_mem_cmd), .val2_out(val2out));

	wire [`WORD_WIDTH - 1 : 0] sign_immediate_extended = { {8{signed_immediate_24_in[23]}}, signed_immediate_24_in}; 
    wire [`WORD_WIDTH - 1 : 0] sign_immediate_extended_xfour = sign_immediate_extended << 2;
    Adder adderPc(.a(pc_in), .b(sign_immediate_extended_xfour), .res(branch_address));

endmodule 