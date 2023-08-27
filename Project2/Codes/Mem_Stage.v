module Mem_Stage #(parameter N = 32)(clk, rst, in, out);
    input clk, rst;
    input [N-1:0]in;
    output [N-1:0] out;
    assign out = in;
endmodule