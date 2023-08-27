module SRAM_Controller(clk, rst, write_en, read_en, address, write_data, read_data, ready, SRAM_DQ, SRAM_ADDR, SRAM_UB_N, SRAM_LB_N,
                       SRAM_WE_N, SRAM_CE_N, SRAM_OE_N);
    input clk, rst;
    input write_en, read_en;
    input [31:0] address;
    input [31:0] write_data;
    output reg [31:0] read_data;
    output reg ready;

    inout [15:0] SRAM_DQ;
    output reg[17:0] SRAM_ADDR;
    output SRAM_UB_N, SRAM_LB_N, SRAM_CE_N, SRAM_OE_N;
    output reg SRAM_WE_N;
    assign SRAM_UB_N = 1'b0;
    assign SRAM_LB_N = 1'b0;
    assign SRAM_CE_N = 1'b0;
    assign SRAM_OE_N = 1'b0;

    wire [31:0] mem_address;
    assign mem_address = address[17:0] - 18'd1024;
    wire [15:0] DataBusRead;
    reg [15:0] data_to_write;

    assign SRAM_DQ = (write_en) ? data_to_write : 16'bz;
    assign DataBusRead = SRAM_DQ;
	reg [2:0] ps, ns;

    parameter [3:0] Idle = 0, State1 = 1, State2 = 2, State3 = 3, State4 = 4, State5 = 5;

    always @(*) begin
        {SRAM_WE_N, ready} = 2'b10;
        case(ps)
            Idle: begin
                ready = (write_en|read_en) ? 1'b0 : 1'b1;
            end

            State1: begin
                SRAM_ADDR = mem_address >> 1;
                if (write_en) begin
                    SRAM_WE_N = 1'b0;
                    data_to_write = write_data[15:0];
                end
                else begin
                    read_data[15:0] <= DataBusRead;
                end
            end

            State2: begin
                SRAM_ADDR = (mem_address + 2) >> 1;
                if (write_en) begin
                    SRAM_WE_N = 1'b0;
                    data_to_write = write_data[31:16];
                end
                else begin
                    read_data[31:16] <= DataBusRead;
                end
            end

            State3: begin
                if (write_en) begin
                    SRAM_WE_N = 1'b1;
                end
            end

            State4: begin
            end

            State5: begin
                ready = 1'b1;
            end
        endcase
    end
    
    always @(*)begin
        case(ps)
            Idle: begin
                ns = (write_en|read_en) ? State1 : Idle;
            end

            State1: begin
                ns = State2;
            end

            State2: begin
                ns = State3;
            end
            
            State3: begin
                ns = State4;
            end
            
            State4: begin
                ns = State5;
            end
            
            State5: begin
                ns = Idle;
            end
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            ps <= Idle;
        end
        else begin
            ps <= ns;
        end
    end

endmodule