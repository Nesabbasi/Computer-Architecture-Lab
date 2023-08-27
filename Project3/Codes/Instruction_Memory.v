`include "defines.v"
module Instruction_Memory(rst, addr, read_instruction);
    input [`INSTRUCTION_LEN - 1 : 0] addr;
    input rst;
    output [`INSTRUCTION_LEN - 1 : 0] read_instruction; 

    reg[7 : 0] instruction[0:`INSTRUCTION_MEM_SIZE - 1];
    assign read_instruction = {instruction[addr], instruction[addr + 1], instruction[addr + 2], instruction[addr + 3]};

    always @(posedge rst) begin
        if (rst) 
        begin
            {instruction[0], instruction[1], instruction[2], instruction[3]} <= `INSTRUCTION_LEN'b1110_00_1_1101_0_0000_0000_000000010100;      //  MOV R0 = 20           R0 = 20
            {instruction[4], instruction[5], instruction[6], instruction[7]} <= `INSTRUCTION_LEN'b1110_00_1_1101_0_0000_0001_101000000001;      //  MOV R1 ,#4096         R1 = 4096
            {instruction[8], instruction[9], instruction[10], instruction[11]} <= `INSTRUCTION_LEN'b1110_00_1_1101_0_0000_0010_000100000011;   //   MOV R2 ,#0xC0000000    R2 = -1073741824
            {instruction[12], instruction[13], instruction[14], instruction[15]} <= `INSTRUCTION_LEN'b1110_00_0_0100_1_0010_0011_000000000010; //   ADDS R3 ,R2,R2         R3 = -2147483648 
            {instruction[16], instruction[17], instruction[18], instruction[19]} <=  `INSTRUCTION_LEN'b1110_00_0_0101_0_0000_0100_000000000000; //ADC R4 ,R0,R0 //R4 = 41
            {instruction[20], instruction[21], instruction[22], instruction[23]} <= `INSTRUCTION_LEN'b1110_00_0_0010_0_0100_0101_000100000100; //SUB R5 ,R4,R4,LSL #2 //R5 = -123 
            {instruction[24], instruction[25], instruction[26], instruction[27]} <= `INSTRUCTION_LEN'b1110_00_0_0110_0_0000_0110_000010100000; //SBC R6 ,R0,R0,LSR #1//R6 = 10
            {instruction[28], instruction[29], instruction[30], instruction[31]} <= `INSTRUCTION_LEN'b1110_00_0_1100_0_0101_0111_000101000010; //ORR    R7 ,R5,R2,ASR #2//R7 = -123
            {instruction[32], instruction[33], instruction[34], instruction[35]} <= `INSTRUCTION_LEN'b1110_00_0_0000_0_0111_1000_000000000011; //AND R8 ,R7,R3   R8 = -2147483648
            {instruction[36], instruction[37], instruction[38], instruction[39]} <= `INSTRUCTION_LEN'b1110_00_0_1111_0_0000_1001_000000000110; //MVNR9 ,R6//R9 = -11
            {instruction[40], instruction[41], instruction[42], instruction[43]} <= `INSTRUCTION_LEN'b1110_00_0_0001_0_0100_1010_000000000101; //EOR R10,R4,R5 //R10 = -84
            {instruction[44], instruction[45], instruction[46], instruction[47]} <= `INSTRUCTION_LEN'b1110_00_0_1010_1_1000_0000_000000000110; //CMPR8 ,R6
            {instruction[48], instruction[49], instruction[50], instruction[51]} <= `INSTRUCTION_LEN'b0001_00_0_0100_0_0001_0001_000000000001; //ADDNER1 ,R1,R1//R1 = 8192
            {instruction[52], instruction[53], instruction[54], instruction[55]} <= `INSTRUCTION_LEN'b1110_00_0_1000_1_1001_0000_000000001000; //TSTR9 ,R8
            {instruction[56], instruction[57], instruction[58], instruction[59]} <= `INSTRUCTION_LEN'b0000_00_0_0100_0_0010_0010_000000000010; //ADDEQ R2 ,R2,R2   //R2 = -1073741824
            {instruction[60], instruction[61], instruction[62], instruction[63]} <= `INSTRUCTION_LEN'b1110_00_1_1101_0_0000_0000_101100000001; //MOVR0 ,#1024//R0 = 1024
            {instruction[64], instruction[65], instruction[66], instruction[67]} <= `INSTRUCTION_LEN'b1110_01_0_0100_0_0000_0001_000000000000; //STRR1 ,[R0],#0//MEM[1024] = 8192
            {instruction[68], instruction[69], instruction[70], instruction[71]} <= `INSTRUCTION_LEN'b1110_01_0_0100_1_0000_1011_000000000000; //LDRR11,[R0],#0//R11 = 8192
        end
    end

endmodule