`define REGFILE_ADDRESS_LEN 4
`define FORW_SEL_FROM_WB 2'b10
`define FORW_SEL_FROM_MEM 2'b01

module Forwarding_Unit (forward_en, WB_wb_en, MEM_wb_en, MEM_dst, WB_dst, src1_in, src2_in, sel_src1, sel_src2);
    input forward_en;
	input WB_wb_en, MEM_wb_en;
    input [`REGFILE_ADDRESS_LEN - 1:0] MEM_dst, WB_dst, src1_in, src2_in;
	
    output reg [1:0] sel_src1, sel_src2;

	always@(*) begin
		{sel_src1, sel_src2} = 4'd0;
        if (forward_en && WB_wb_en) begin
            if (WB_dst == src1_in) begin
                sel_src1 = `FORW_SEL_FROM_WB; 
            end
            
            if (WB_dst == src2_in) begin
                sel_src2 = `FORW_SEL_FROM_WB; 
            end
        end
        if (forward_en && MEM_wb_en) begin
            if (MEM_dst == src1_in) begin
                sel_src1 = `FORW_SEL_FROM_MEM;
            end
            
            if (MEM_dst == src2_in) begin
                sel_src2 = `FORW_SEL_FROM_MEM;
            end
        end
	end
endmodule