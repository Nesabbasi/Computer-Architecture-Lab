module Cache_controller (clk, rst, address, write_data, MEM_R_EN, MEM_W_EN, read_data, ready, sram_address, sram_write_data, sram_write, sram_read, sram_read_data, sram_ready);

    input clk, rst, sram_ready, MEM_R_EN, MEM_W_EN;
    input [31:0] address;
    input [31:0] write_data;
    input [63:0] sram_read_data;

    output ready, sram_write, sram_read;
    output [31:0] read_data, sram_address, sram_write_data;

    wire hit;
    assign ready = sram_ready;

    wire [2:0] offset;
    wire [5:0] index;
    wire [9:0] tag;
    assign offset = address[2:0];
    assign index = address[8:3];
    assign tag = address[18:9];

    reg [31:0] way0_data0 [63:0];
    reg [31:0] way0_data1 [63:0];
    reg [31:0] way1_data0 [63:0];
    reg [31:0] way1_data1 [63:0];

    reg way0_valid [63:0];
    reg way1_valid [63:0];

    reg [9:0] way0_tag [63:0];
    reg [9:0] way1_tag [63:0];

    reg LRU [63:0];

    wire hit_way0, hit_way1;
    assign hit_way0 = (way0_valid[index]) & (way0_tag[index] == tag);
    assign hit_way1 = (way1_valid[index]) & (way1_tag[index] == tag);
    assign hit = hit_way0 | hit_way1;
    assign sram_read = MEM_R_EN & ~hit;

    wire [31:0] read_data_temp;
    wire [31:0] result_hit0, result_hit1, result_low_high;

    Mux2To1 #(32) mux_hit_way0 (result_hit0, way0_data0[index], way0_data1[index], offset[2]);
    Mux2To1 #(32) mux_hit_way1 (result_hit1, way1_data0[index], way1_data1[index], offset[2]);
    Mux2To1 #(32) mux_result_low_high (result_low_high, sram_read_data[31:0], sram_read_data[63:32], offset[2]);

    assign read_data_temp = hit ? (hit_way0 ? result_hit0 : hit_way1 ? result_hit1 : 32'bz) : sram_ready ? result_low_high : 32'bz;

    integer i;
    always @(posedge rst, posedge clk) begin
        if (rst)
            for(i = 0; i < 64; i = i + 1)
                LRU[i] <= 0;

        else if (MEM_R_EN) begin
            if (hit_way0)
                LRU[index] <= 0;

            if (hit_way1)
                LRU[index] <= 1;
        end 
    
        else if (~hit & sram_ready) begin
            if(way0_valid[index] == 1'b1 & LRU[index] == 1'b1)
                LRU[index] <= 1'b0;

            else if(way1_valid[index] == 1'b1 & LRU[index] == 1'b0)
                LRU[index] <= 1'b1;           
        end
    end

    assign read_data = MEM_R_EN ? read_data_temp : 32'bz;

    always @(posedge rst, posedge clk) begin
        if (rst)begin
            for(i = 0; i < 64; i = i + 1) begin
                {way0_valid[i], way1_valid[i]} <= 0;
            end
        end

        else if (MEM_R_EN & ~hit & sram_ready) begin
            if (LRU[index] == 1) begin
                {way0_data1[index], way0_data0[index]} <= sram_read_data;
                way0_valid[index] <= 1;
                way0_tag[index] <= tag;
            end

            else if (LRU[index] == 0) begin
                {way1_data1[index], way1_data0[index]} <= sram_read_data;
                way1_valid[index] <= 1;
                way1_tag[index] <= tag;
            end
        end       

        else if (MEM_W_EN) begin
            if (hit_way0) begin
                way0_valid[index] <= 0;
            end

            if (hit_way1) begin
                way1_valid[index] <= 0;
            end
        end
    end

    assign sram_address = address;
    assign sram_write_data = write_data;
    assign sram_write = MEM_W_EN;

    
endmodule