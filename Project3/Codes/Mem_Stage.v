`include "defines.v"
`include "Data_Memory.v"
module Mem_Stage (clk, rst, dst, ALU_res, val_Rm, mem_read, mem_write, WB_en, dst_out, ALU_res_out, mem_out, mem_read_out, WB_en_out);
    input clk, rst;
    input [`REG_FILE_ADDRESS_LEN-1:0] dst;
    input [`WORD_WIDTH-1:0] ALU_res;
    input [`WORD_WIDTH-1:0] val_Rm;
    input mem_read, mem_write, WB_en;

    output [`REG_FILE_ADDRESS_LEN-1:0] dst_out;
    output [`WORD_WIDTH-1:0] ALU_res_out;
    output [`WORD_WIDTH-1:0] mem_out;
    output mem_read_out, WB_en_out;

    assign dst_out = dst;
    assign mem_read_out = mem_read;
    assign WB_en_out = WB_en;
    assign ALU_res_out = ALU_res;

    Data_Memory data_mem(.clk(clk), .rst(rst), .addr(ALU_res), .write_data(val_Rm), .mem_read(mem_read), .mem_write(mem_write), .read_data(mem_out));

endmodule