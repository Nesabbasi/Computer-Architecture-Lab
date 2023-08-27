module IF_Stage_Reg #(parameter N = 32)(clk, rst, freeze, flush, pcIn, instructionIn, pcOut, instruction);
    input clk, rst, freeze, flush;
    input [N-1:0] pcIn;
    input [N-1:0] instructionIn;
    output reg [N-1:0] pcOut;
    output reg [N-1:0] instruction;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            pcOut <= 0;
            instruction <= 0;
        end  
        else if(flush) begin
            pcOut <= 0;
            instruction <= 0;
        end
        else if(~freeze) begin
            pcOut <= pcIn;
            instruction <= instructionIn;
        end    
        else begin
            pcOut <= pcIn;
            instruction <= instructionIn;
        end 
    end
endmodule