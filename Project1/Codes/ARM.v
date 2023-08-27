module ARM(clk, rst, out);
    input clk, rst;
    output [31:0] out;
    wire freeze, branch_taken;
    wire [31:0] branchAddr, IFStagePcOut, IFRegPcOut, IFStageInstructionOut, IFRegInstructionOut;
    wire [31:0] IFout, IDout, IDExRegOut, execOut, exMemRegOut, memOut, memWbRegOut, IFIDregOut;

    IF iff(.clk(clk), .rst(rst), .freeze(freeze), .branch_taken(branch_taken), .branchAddr(branchAddr), .pc(IFStagePcOut), .instruction(IFStageInstructionOut));
    IFIDreg iFIDreg(.clk(clk), .rst(rst), .freeze(freeze), .flush(branch_taken), .pcIn(IFStagePcOut), .instructionIn(IFStageInstructionOut), .pcOut(IFRegPcOut), .instruction(IFRegInstructionOut));
    ID id(.clk(clk), .rst(rst), .in(IFRegPcOut), .out(IDout));
    IDExReg idExReg(.clk(clk), .rst(rst), .in(IDout), .out(IDExRegOut));
    Exec exec(.clk(clk), .rst(rst), .in(IDExRegOut), .out(execOut));
    ExMemReg exMemReg(.clk(clk), .rst(rst), .in(execOut), .out(exMemRegOut));
    Mem mem(.clk(clk), .rst(rst), .in(exMemRegOut), .out(memOut));
    MemWBReg memWbReg(.clk(clk), .rst(rst), .in(memOut), .out(memWbRegOut));
    WB wb(.clk(clk), .rst(rst), .in(memWbRegOut), .out(out));
endmodule