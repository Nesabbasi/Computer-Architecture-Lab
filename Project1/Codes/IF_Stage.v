module Adder #(parameter bit = 32)(a, b, res);
    input [bit-1:0] a, b;
    output [bit-1:0] res;
    assign res = a + b;
endmodule

module InstructionMem #(parameter N = 32)(instruction, address);
    output reg[N-1:0] instruction;
    input [N-1:0] address;
    always @*
        case(address)
            32'd0: instruction = 32'b000000_00001_00010_00000_00000000000;
            32'd1: instruction = 32'b000000_00011_00100_00000_00000000000;
            32'd2: instruction = 32'b000000_00101_00110_00000_00000000000;
            32'd3: instruction = 32'b000000_00111_01000_00010_00000000000;
            32'd4: instruction = 32'b000000_01001_01010_00011_00000000000;
            32'd5: instruction = 32'b000000_01011_01100_00000_00000000000;
            32'd6: instruction = 32'b000000_01101_01110_00000_00000000000;
        endcase
   endmodule

module PCRegister # (parameter bit = 32)(out, in, rst, freeze, clk);
    input [bit - 1:0] in;
    input rst, freeze, clk;
    output reg [bit - 1:0] out;
    always@(posedge clk, posedge rst) begin
        if(rst)
            out <= {bit{1'b0}};
        else if(~freeze)
            out <= in;
        else
            out <= out; 
    end
endmodule

module Mux2To1 # (parameter bit = 32)(out, in1, in2, sel);
    input [bit - 1:0] in1, in2;
    input sel;
    output [bit - 1:0] out;
    assign out = (sel == 1'b0) ? in1 : in2;
endmodule

module IF_Stage(clk, rst, freeze, branch_taken, branchAddr, pc, instruction);
    input clk, rst, freeze, branch_taken;
    input [31:0] branchAddr;
    output [31:0] pc, instruction;

    wire [31:0] adderOut;
    wire [31:0] PCout;
    wire [31:0] muxIFout;
    
    Adder adder(.a(PCout), .b(32'd4), .res(adderOut));
    InstructionMem instMem(.instruction(instruction), .address(PCout));
    Mux2To1 muxIF(.out(muxIFout),.in1(adderOut), .in2(32'd0), .sel(1'd0));
    PCRegister PCReg(.out(PCout), .in(muxIFout), .rst(rst), .freeze(1'd0), .clk(clk));
    
    assign pc = muxIFout;
endmodule
