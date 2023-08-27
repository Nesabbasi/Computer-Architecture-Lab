`include "defines.v"
module Data_Memory(clk, rst, addr, write_data, mem_read, mem_write, read_data);
    input [`INSTRUCTION_LEN - 1 : 0] addr, write_data;
    input clk, rst, mem_read, mem_write;
    output [`INSTRUCTION_LEN - 1 : 0] read_data; 

    reg[7 : 0] data[0:`INSTRUCTION_MEM_SIZE - 1];
    integer i;
     
    assign read_data = mem_read ?  {data[addr], data[addr + 1], data[addr + 2], data[addr + 3]} : `INSTRUCTION_LEN'b0;

    wire [`INSTRUCTION_LEN - 1 : 0] new_addr;
    assign new_addr = { {addr[`INSTRUCTION_LEN - 1 : 2]}, {2'b00} };

    always@(posedge clk, posedge rst)begin
        if(rst)
            for(i = 0; i < `INSTRUCTION_MEM_SIZE; i = i + 1) 
                data[i] <= 8'd0;
        if (mem_write)begin
            {data[new_addr], data[new_addr + 1], data[new_addr + 2], data[new_addr + 3]} = write_data;
        end
    end

endmodule
