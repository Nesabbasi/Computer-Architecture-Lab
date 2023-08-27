`include "Mux2To1.v"
`include "Instruction_Memory.v"
module Adder #(parameter bit = 32)(a, b, res);
    input [bit-1:0] a, b;
    output [bit-1:0] res;
    assign res = a + b;
endmodule

// module InstructionMem #(parameter N = 32)(instruction, address);
//     output reg[N-1:0] instruction;
//     input [N-1:0] address;
//     always @*
//         case(address)
//             32'd0: instruction = 32'b1110_00_1_1101_0_0000_0000_000000010100;
//             32'd1: instruction = 32'b1110_00_1_1101_0_0000_0001_101000000001;
//             32'd2: instruction = 32'b1110_00_1_1101_0_0000_0010_000100000011;
//             32'd3: instruction = 32'b1110_00_0_0100_1_0010_0011_000000000010;
//             32'd4: instruction = 32'b1110_00_0_0101_0_0000_0100_000000000000;
//             32'd5: instruction = 32'b1110_00_0_0010_0_0100_0101_000100000100;
//             32'd6: instruction = 32'b1110_00_0_0110_0_0000_0110_000010100000;
//             32'd7: instruction = 32'b1110_00_0_1100_0_0101_0111_000101000010;
//             32'd8: instruction = 32'b1110_00_0_0000_0_0111_1000_000000000011;
//             32'd9: instruction = 32'b1110_00_0_1111_0_0000_1001_000000000110;
//             32'd10: instruction = 32'b1110_00_0_0001_0_0100_1010_000000000101;
//             32'd11: instruction = 32'b1110_00_0_1010_1_1000_0000_000000000110;
//             32'd12: instruction = 32'b0001_00_0_0100_0_0001_0001_000000000001;
//             32'd13: instruction = 32'b1110_00_0_1000_1_1001_0000_000000001000;
//             32'd14: instruction = 32'b0000_00_0_0100_0_0010_0010_000000000010;
//             32'd15: instruction = 32'b1110_00_1_1101_0_0000_0000_101100000001;
//             32'd16: instruction = 32'b1110_01_0_0100_0_0000_0001_000000000000;
//             32'd17: instruction = 32'b1110_01_0_0100_1_0000_1011_000000000000;
//         endcase
//    endmodule

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


module IF_Stage(clk, rst, freeze, branch_taken, branchAddr, pc, instruction);
    input clk, rst, freeze, branch_taken;
    input [31:0] branchAddr;
    output [31:0] pc, instruction;

    wire [31:0] adderOut;
    wire [31:0] PCout;
    wire [31:0] muxIFout;
    
    Adder adder(.a(PCout), .b(32'd4), .res(adderOut));
    Instruction_Memory instMem(.rst(rst), .addr(PCout), .read_instruction(instruction));
    Mux2To1 muxIF(.out(muxIFout),.in1(adderOut), .in2(32'd0), .sel(1'd0));
    PCRegister PCReg(.out(PCout), .in(muxIFout), .rst(rst), .freeze(1'd0), .clk(clk));
    
    assign pc = muxIFout;

endmodule
