`include "defines.v"
module Register_File(reg1, reg2, result_WB, src1, src2, dest_wb, writeBackEn, rst, clk);
    input [`WORD_WIDTH-1:0] result_WB;
    input [`REG_FILE_ADDRESS_LEN-1:0] src1, src2, dest_wb;
    input clk, rst, writeBackEn;
    output [`WORD_WIDTH-1:0] reg1, reg2;
    reg [`WORD_WIDTH-1:0] registerFile [0:`REG_FILE_SIZE-1];
    integer i;

    initial begin
        for(i = 0; i < `REG_FILE_SIZE; i = i + 1) 
            registerFile[i] <= i;
    end

    always@(posedge clk, posedge rst)begin
        if(rst)
            for(i = 0; i < `REG_FILE_SIZE; i = i + 1) 
                registerFile[i] <= i;
        else if(writeBackEn)
                registerFile[dest_wb] <= result_WB;
    end

    assign reg1 = registerFile[src1];
    assign reg2 = registerFile[src2];
endmodule