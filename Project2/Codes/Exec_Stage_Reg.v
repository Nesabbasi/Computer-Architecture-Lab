module Exec_Stage_Reg #(parameter N = 32)(clk, rst, in, out);
    input clk, rst;
    input [N-1:0]in;
    output reg [N-1:0] out;
    always @(posedge clk,posedge rst) begin
        if (rst)
            out <= {N{1'b0}};
        else
            out <= in;
    end
endmodule