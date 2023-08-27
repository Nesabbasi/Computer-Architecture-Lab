`timescale 1ns/1ns

`include "Arm.v"
module TB();
    reg clk = 1'b0, rst = 1'b0;
    ARM arm(clk, rst);
    always #5 clk = ~clk;
    initial begin
        #20 rst = 1'b1;
        #80 rst = 1'b0;
        #7000 $stop;
    end
endmodule