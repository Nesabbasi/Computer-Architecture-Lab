`include "defines.v"
module Mem_Stage_Reg (clk, rst, dst, ALU_res, mem_data, mem_read, WB_en, dst_out, ALU_res_out, mem_data_out, mem_read_out, WB_en_out);
    input clk, rst;
    input [`REG_FILE_ADDRESS_LEN-1:0] dst;
    input [`WORD_WIDTH-1:0] ALU_res;
    input [`WORD_WIDTH-1:0] mem_data;
    input mem_read, WB_en;

    output reg [`REG_FILE_ADDRESS_LEN-1:0] dst_out;
    output reg [`WORD_WIDTH-1:0] ALU_res_out;
    output reg [`WORD_WIDTH-1:0] mem_data_out;
    output reg mem_read_out, WB_en_out;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            dst_out <= 0;
            ALU_res_out <= 0;
            mem_data_out <= 0;
            mem_read_out <= 0;
            WB_en_out <= 0;
        end
        else begin
            dst_out <= dst;
            ALU_res_out <= ALU_res;
            mem_data_out <= mem_data;
            mem_read_out <= mem_read;
            WB_en_out <= WB_en;
        end
    end
endmodule