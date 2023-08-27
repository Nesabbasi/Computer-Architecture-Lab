module Adder #(parameter bit = 32)(a, b, res);
    input [bit-1:0] a, b;
    output [bit-1:0] res;
    assign res = a + b;
endmodule