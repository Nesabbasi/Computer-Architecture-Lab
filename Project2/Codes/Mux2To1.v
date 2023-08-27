module Mux2To1 # (parameter bit = 32)(out, in1, in2, sel);
    input [bit - 1:0] in1, in2;
    input sel;
    output [bit - 1:0] out;
    assign out = (sel == 1'b0) ? in1 : in2;
endmodule
