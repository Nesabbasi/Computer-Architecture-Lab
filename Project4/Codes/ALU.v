`include "defines.v"
module ALU ( val1, val2, cin, EX_command, ALU_out, SR);
    input [`WORD_WIDTH-1:0] val1, val2;
    input cin;
    input [3:0] EX_command;
    output reg [`WORD_WIDTH-1:0] ALU_out;
    output [3:0] SR;

    reg V, C;
    wire N, Z;

    always @(*) begin
        {V, C} = 2'd0;
        case (EX_command)
            `EX_MOV: begin
                ALU_out = val2;
            end
            `EX_MVN: begin
                ALU_out = ~val2;
            end
            `EX_ADD: begin
                {C, ALU_out} = val1 + val2;
                V = ((val1[`WORD_WIDTH - 1] == val2[`WORD_WIDTH - 1]) & (ALU_out[`WORD_WIDTH - 1] != val1[`WORD_WIDTH - 1]));
            end
            `EX_ADC: begin
                {C, ALU_out} = val1 + val2 + {31'd0, cin};
                V = ((val1[`WORD_WIDTH - 1] == val2[`WORD_WIDTH - 1]) & (ALU_out[`WORD_WIDTH - 1] != val1[`WORD_WIDTH - 1]));
            end
            `EX_SUB: begin
               {C, ALU_out} = val1 - val2;
                V = ((val1[`WORD_WIDTH - 1] != val2[`WORD_WIDTH - 1]) & (ALU_out[`WORD_WIDTH - 1] != val1[`WORD_WIDTH - 1]));

            end
            `EX_SBC: begin
               {C, ALU_out} = val1 - val2 - {31'd0, ~cin};
                V = ((val1[`WORD_WIDTH - 1] != val2[`WORD_WIDTH - 1]) & (ALU_out[`WORD_WIDTH - 1] != val1[`WORD_WIDTH - 1]));
            end
            `EX_AND: begin
                ALU_out = val1 & val2;
            end
            `EX_ORR: begin
                ALU_out = val1 | val2;
            end
            `EX_EOR: begin
                ALU_out = val1 ^ val2;
            end
            default: ALU_out = {`WORD_WIDTH{1'b0}};
            // `EX_CMP: begin
            //     {C, ALU_out} = {val1[`WORD_WIDTH-1], val1} - {val2[`WORD_WIDTH-1], val2};
            //     V = ((val1[`WORD_WIDTH - 1] == val2[`WORD_WIDTH - 1]) & (ALU_out[`WORD_WIDTH - 1] != val1[`WORD_WIDTH - 1]));
            // end
            // `EX_TST: begin
            //     ALU_out = val1 & val2;
            // end
            // `EX_LDR: begin
            //     ALU_out = val1 + val2;
            // end
            // `EX_STR: begin
            //     ALU_out = val1 + val2;
            // end

        endcase
    end


    assign SR = {Z, C, N, V};
    assign N = ALU_out[`WORD_WIDTH-1];
    assign Z = |ALU_out ? 1'b0:1'b1;

endmodule