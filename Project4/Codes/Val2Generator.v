`include "defines.v"

module Val2Generator(val_Rm, shift_operand, immediate, is_mem_cmd, val2_out);
    input [`WORD_WIDTH-1:0] val_Rm;
    input [`SHIFTER_OPERAND_WIDTH-1:0] shift_operand;
    input immediate, is_mem_cmd;
    output reg [`WORD_WIDTH-1:0] val2_out;

    reg [2 * (`WORD_WIDTH) - 1 : 0] tmp;
    integer i;
    always @(val_Rm, shift_operand, immediate, is_mem_cmd) begin
        val2_out = `WORD_WIDTH'b0;
        tmp = 0;
        if (is_mem_cmd == 1'b0) begin

            if (immediate == 1'b1) begin
                val2_out = {24'b0 ,shift_operand[7 : 0]};
                for (i = 0; i < 2 * shift_operand[11:8]; i = i + 1) begin
                    val2_out = {val2_out[0], val2_out[31:1]};
                end

            end 
            else if(immediate == 1'b0 && shift_operand[4] == 0) begin
                case(shift_operand[6:5])
                    `LSL_SHIFT : begin
                        val2_out = val_Rm << shift_operand[11 : 7];
                    end
                    `LSR_SHIFT : begin
                        val2_out = val_Rm >> shift_operand[11 : 7];
                    end
                    `ASR_SHIFT : begin
                        val2_out = $signed(val_Rm) >>> shift_operand[11 : 7];
                    end
                    `ROR_SHIFT : begin
                       val2_out = val_Rm;
                        for (i = 0; i < shift_operand[11:7]; i = i + 1) begin
                            val2_out = {val2_out[0], val2_out[31:1]};
                        end
                    end
                endcase
            end
        end 
        else //is mem_command
        begin
            val2_out = { {20{shift_operand[11]}} , shift_operand}; 
        end

    end
endmodule