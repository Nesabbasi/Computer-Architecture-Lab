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

// `include "SRAM_Controller.v"
// `include "Mux2To1.v"
module Mem_Stage (clk, rst, dst, ALU_res, val_Rm, mem_read, mem_write, WB_en, dst_out, ALU_res_out, mem_out, mem_read_out, WB_en_out,
                  ready, SRAM_UB_N, SRAM_LB_N, SRAM_WE_N, SRAM_CE_N, SRAM_OE_N, SRAM_ADDR, SRAM_DQ);
    input clk, rst;
    input [`REG_FILE_ADDRESS_LEN-1:0] dst;
    input [`WORD_WIDTH-1:0] ALU_res;
    input [`WORD_WIDTH-1:0] val_Rm;
    input mem_read, mem_write, WB_en;

    output [`REG_FILE_ADDRESS_LEN-1:0] dst_out;
    output [`WORD_WIDTH-1:0] ALU_res_out;
    output [`WORD_WIDTH-1:0] mem_out;
    output mem_read_out, WB_en_out;
    output ready, SRAM_UB_N, SRAM_LB_N, SRAM_WE_N, SRAM_CE_N, SRAM_OE_N;
    output [17:0] SRAM_ADDR;
    inout [15:0] SRAM_DQ;

    assign dst_out = dst;
    assign mem_read_out = mem_read;
    assign ALU_res_out = ALU_res;
    wire freeze;
    assign freeze = ~ready;

    wire sram_writeEn, sram_readEn, sram_ready;
    wire [`DATA_MEM_SIZE-1:0] sram_read_data;
    SRAM_Controller sram_controller(.clk(clk), .rst(rst), .write_en(sram_writeEn), .read_en(sram_readEn), .address(ALU_res), .write_data(val_Rm),
                                    .read_data(sram_read_data), .ready(sram_ready), .SRAM_DQ(SRAM_DQ), .SRAM_ADDR(SRAM_ADDR), .SRAM_UB_N(SRAM_UB_N), .SRAM_LB_N(SRAM_LB_N),
                                    .SRAM_WE_N(SRAM_WE_N), .SRAM_CE_N(SRAM_CE_N), .SRAM_OE_N(SRAM_OE_N));

    Cache_controller cache_controller(.clk(clk), .rst(rst), .address(ALU_res), .write_data(val_Rm), .MEM_R_EN(mem_read), .MEM_W_EN(mem_write), .read_data(mem_out), 
                                      .ready(ready), .sram_write(sram_writeEn), .sram_read(sram_readEn), .sram_read_data(sram_read_data), .sram_ready(sram_ready));     

    Mux2To1 #(1) MUX_2_to_1_WB_EN (.out(WB_en_out), .in1(WB_en), .in2(1'b0), .sel(freeze));

endmodule