module IDExReg #(parameter N = 32)(clk, rst, in, out);
    input clk, rst;
    input [N-1:0]in;
    output reg [N-1:0] out;
    always @(posedge clk, posedge rst) begin
        if (rst)
            out <= {32'd0};
        else
            out <= in;
    end
endmodule