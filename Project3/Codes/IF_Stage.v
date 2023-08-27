`include "Mux2To1.v"
`include "Instruction_Memory.v"
`include "Adder.v"

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
