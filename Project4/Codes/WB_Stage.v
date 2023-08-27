`include "defines.v"
`include "Mux2To1.v"
module WB_Stage(clk, rst, dst, ALU_res, mem_data, mem_read, WB_en, WB_dst, WB_en_out, WB_value);
    input clk, rst;
    input [`REG_FILE_ADDRESS_LEN-1:0] dst;
    input [`WORD_WIDTH-1:0] ALU_res;
    input [`WORD_WIDTH-1:0] mem_data;
    input mem_read, WB_en;

    output [`REG_FILE_ADDRESS_LEN-1:0] WB_dst;
    output WB_en_out;
    output [`WORD_WIDTH-1:0] WB_value;

    assign WB_dst = dst;
    assign WB_en_out = WB_en;

    Mux2To1 #(`WORD_WIDTH) MUX_2_to_1_Reg_File (.out(WB_value), .in1(ALU_res), .in2(mem_data), .sel(mem_read));

endmodule