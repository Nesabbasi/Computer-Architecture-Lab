`timescale 1ns/1ns

`include "Arm.v"
module TB();
    reg clk = 1'b0, rst = 1'b0, forward_en = 1'b1;
    ARM arm(clk, rst, forward_en);
    always #5 clk = ~clk;
    initial begin
        rst = 1'b1;
        #10 rst = 1'b0;
       #3000 $stop;
    end
endmodule