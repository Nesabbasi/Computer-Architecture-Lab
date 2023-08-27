`timescale 1ns / 1ns

`define WORD_WIDTH 32
`define REG_FILE_ADDRESS_LEN 4
`define REG_FILE_SIZE 16
`define MEMORY_DATA_LEN 8
`define MEMORY_SIZE 2048
`define SIGNED_IMM_WIDTH 24
`define SHIFTER_OPERAND_WIDTH 12

`define INSTRUCTION_LEN         32
`define INSTRUCTION_MEM_SIZE    2048
`define DATA_MEM_SIZE 64

`define LSL_SHIFT 2'b00
`define LSR_SHIFT 2'b01
`define ASR_SHIFT 2'b10
`define ROR_SHIFT 2'b11

`define MODE_ARITHMETIC 2'b00
`define MODE_MEM 2'b01
`define MODE_BRANCH 2'b10

`define EX_MOV 4'b0001
`define EX_MVN 4'b1001
`define EX_ADD 4'b0010
`define EX_ADC 4'b0011
`define EX_SUB 4'b0100
`define EX_SBC 4'b0101
`define EX_AND 4'b0110
`define EX_ORR 4'b0111
`define EX_EOR 4'b1000
`define EX_CMP 4'b0100     ///1100
`define EX_TST 4'b0110     ///1110
`define EX_LDR 4'b0010     ///1010
`define EX_STR 4'b0010     ///1010

`define OP_MOV 4'b1101
`define OP_MVN 4'b1111
`define OP_ADD 4'b0100
`define OP_ADC 4'b0101
`define OP_SUB 4'b0010
`define OP_SBC 4'b0110
`define OP_AND 4'b0000
`define OP_ORR 4'b1100
`define OP_EOR 4'b0001
`define OP_CMP 4'b1010
`define OP_TST 4'b1000
`define OP_LDR 4'b0100
`define OP_STR 4'b0100

module PCRegister # (parameter bit = 32)(out, in, rst, freeze, clk);
    input [bit - 1:0] in;
    input rst, freeze, clk;
    output reg [bit - 1:0] out;
    always@(posedge clk, posedge rst) begin
        if(rst)
            out <= {bit{1'b0}};
        // else if (flush)
        //      out <= {bit{1'b0}};
        else if(~freeze)
            out <= in;
        // else
        //     out <= out; 
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
    Mux2To1 muxIF(.out(muxIFout),.in1(adderOut), .in2(branchAddr), .sel(branch_taken));
    PCRegister PCReg(.out(PCout), .in(muxIFout), .rst(rst), .freeze(freeze), .clk(clk));
    
    assign pc = adderOut;

endmodule
