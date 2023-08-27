`timescale 1ns/1ns

`include "Arm.v"
module TB();
    reg clk = 1'b0, rst = 1'b0, forward_en = 1'b1;
    wire SRAM_UB_N, SRAM_LB_N, SRAM_WE_N, SRAM_CE_N, SRAM_OE_N;
    wire [17:0] SRAM_ADDR;
    wire [15:0] SRAM_DQ; 
    SRAM sram(clk, rst, SRAM_WE_N, SRAM_ADDR, SRAM_DQ);
    ARM arm(clk, rst, forward_en, SRAM_ADDR, SRAM_DQ, SRAM_UB_N, SRAM_LB_N, SRAM_WE_N, SRAM_CE_N, SRAM_OE_N);
    always #5 clk = ~clk;
    initial begin
        rst = 1'b1;
        #10 rst = 1'b0;
       #6000 $stop;
    end
endmodule