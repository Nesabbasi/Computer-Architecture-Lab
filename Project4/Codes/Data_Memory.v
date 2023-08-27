`include "defines.v"
module Data_Memory(clk, rst, addr, write_data, mem_read, mem_write, read_data);
    input [`INSTRUCTION_LEN - 1 : 0] addr, write_data;
    input clk, rst, mem_read, mem_write;
    output reg [`INSTRUCTION_LEN - 1 : 0] read_data; 

    reg[`INSTRUCTION_LEN - 1 : 0] data[0:`DATA_MEM_SIZE - 1];

    integer i;
    wire [31:0] dataAdr, adr;
    assign dataAdr = addr - 32'd1024;
    assign adr = {2'b00, dataAdr[31:2]};
    
    always @(mem_read or adr) begin
        if (mem_read)
            read_data = data[adr];
    end

    always@(negedge clk, posedge rst)begin
        if(rst)
            for(i = 0; i < `DATA_MEM_SIZE; i = i + 1) 
                data[i] <= 32'd0;
        if (mem_write)begin
            data[adr] = write_data;
        end
    end

endmodule

