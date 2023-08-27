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

module Exec_Stage(clk, rst, pc_in, mem_read_in, mem_write_in, S, B, WB_en_in, execute_cmd_in, immediate_in, signed_immediate_24_in, shift_operand_in,
				 val_Rn_in, val_Rm_in, SR_in, dst_in, alu_res_in_MEM, wb_value_WB, alu_mux_src_1_sel, alu_mux_src_2_sel, alu_out, branch_address, 
				 status_reg_out, branch_taken_out, WB_en_out, mem_read_out, mem_write_out, dst_out, val_Rm_out);

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
	input [`WORD_WIDTH - 1 : 0] alu_res_in_MEM, wb_value_WB;
	input [1:0] alu_mux_src_1_sel;
	input [1:0] alu_mux_src_2_sel;

	output [`WORD_WIDTH - 1 : 0] alu_out;
	output [`WORD_WIDTH - 1 : 0] branch_address;
	output [3:0] status_reg_out;
	output branch_taken_out, WB_en_out, mem_read_out, mem_write_out;
	output [`REG_FILE_ADDRESS_LEN-1:0] dst_out;
	output [`WORD_WIDTH - 1 : 0] val_Rm_out;
	

	wire [3:0] status_bits;
	wire [`WORD_WIDTH - 1 : 0] val2out;
	wire [`WORD_WIDTH - 1 : 0] alu_mux_Rn_out, alu_mux_Rm_out;
	
	ALU alu(.val1(alu_mux_Rn_out), .val2(val2out), .cin(SR_in[2]), .EX_command(execute_cmd_in), .ALU_out(alu_out), .SR(status_bits));
	Mux3To1 #(`WORD_WIDTH) alu_mux_src_1(.in1(val_Rn_in), .in2(alu_res_in_MEM), .in3(wb_value_WB), .sel(alu_mux_src_1_sel), .out(alu_mux_Rn_out)); 
	Mux3To1 #(`WORD_WIDTH) alu_mux_src_2(.in1(val_Rm_in), .in2(alu_res_in_MEM), .in3(wb_value_WB), .sel(alu_mux_src_2_sel), .out(alu_mux_Rm_out));



	wire is_mem_cmd;
	assign is_mem_cmd = mem_read_in | mem_write_in;

	assign dst_out = dst_in;
	assign branch_taken_out = B;
	assign mem_read_out = mem_read_in;
	assign mem_write_out = mem_write_in;
	assign WB_en_out = WB_en_in;

	Status_Register status_ref(.clk(clk), .rst(rst), .ld(S), .in(status_bits), .out(status_reg_out));

	assign val_Rm_out = alu_mux_Rm_out; 
    Val2Generator v2g(.val_Rm(alu_mux_Rm_out), .shift_operand(shift_operand_in), .immediate(immediate_in), .is_mem_cmd(is_mem_cmd), .val2_out(val2out));

	wire [`WORD_WIDTH - 1 : 0] sign_immediate_extended = { {8{signed_immediate_24_in[23]}}, signed_immediate_24_in}; 
    wire [`WORD_WIDTH - 1 : 0] sign_immediate_extended_xfour = sign_immediate_extended << 2;
    Adder adderPc(.a(pc_in), .b(sign_immediate_extended_xfour), .res(branch_address));

endmodule 