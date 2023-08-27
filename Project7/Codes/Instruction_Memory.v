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

module Instruction_Memory(rst, addr, read_instruction);
    input [`INSTRUCTION_LEN - 1 : 0] addr;
    input rst;
    output [`INSTRUCTION_LEN - 1 : 0] read_instruction; 
    
    reg[7 : 0] instruction[0:`INSTRUCTION_MEM_SIZE - 1];
    assign read_instruction = {instruction[addr], instruction[addr + 1], instruction[addr + 2], instruction[addr + 3]};

    always @(posedge rst) begin
        if (rst) 
        begin
            {instruction[0],   instruction[1],   instruction[2],   instruction[3]}   <= `INSTRUCTION_LEN'b1110_00_1_1101_0_0000_0000_000000010100; // MOV   R0,  #20            -> R0 = 20
            {instruction[4],   instruction[5],   instruction[6],   instruction[7]}   <= `INSTRUCTION_LEN'b1110_00_1_1101_0_0000_0001_101000000001; // MOV   R1,  #4096          -> R1 = 4096
            {instruction[8],   instruction[9],   instruction[10],  instruction[11]}  <= `INSTRUCTION_LEN'b1110_00_1_1101_0_0000_0010_000100000011; // MOV   R2,  #0xC00000000   -> R2 = -1073741824
            {instruction[12],  instruction[13],  instruction[14],  instruction[15]}  <= `INSTRUCTION_LEN'b1110_00_0_0100_1_0010_0011_000000000010; // ADDS  R3,  R2, R2         -> R3 = -2147483648
            {instruction[16],  instruction[17],  instruction[18],  instruction[19]}  <= `INSTRUCTION_LEN'b1110_00_0_0101_0_0000_0100_000000000000; // ADC   R4,  R0, R0         -> R4 = 41
            {instruction[20],  instruction[21],  instruction[22],  instruction[23]}  <= `INSTRUCTION_LEN'b1110_00_0_0010_0_0100_0101_000100000100; // SUB   R5,  R4, R4, LSL #2 -> R5= -123
            {instruction[24],  instruction[25],  instruction[26],  instruction[27]}  <= `INSTRUCTION_LEN'b1110_00_0_0110_0_0000_0110_000010100000; // SBC   R6,  R0, R0, LSR #1 -> R6 = 10
            {instruction[28],  instruction[29],  instruction[30],  instruction[31]}  <= `INSTRUCTION_LEN'b1110_00_0_1100_0_0101_0111_000101000010; // ORR   R7,  R5, R2, ASR #2 -> R7 = -123
            {instruction[32],  instruction[33],  instruction[34],  instruction[35]}  <= `INSTRUCTION_LEN'b1110_00_0_0000_0_0111_1000_000000000011; // AND   R8,  R7, R3         -> R8 = -2147483648
            {instruction[36],  instruction[37],  instruction[38],  instruction[39]}  <= `INSTRUCTION_LEN'b1110_00_0_1111_0_0000_1001_000000000110; // MVN   R9,  R6             -> R9 = -11
            {instruction[40],  instruction[41],  instruction[42],  instruction[43]}  <= `INSTRUCTION_LEN'b1110_00_0_0001_0_0100_1010_000000000101; // EOR   R10, R4, R5         -> R10 = -84
            {instruction[44],  instruction[45],  instruction[46],  instruction[47]}  <= `INSTRUCTION_LEN'b1110_00_0_1010_1_1000_0000_000000000110; // CMP   R8,  R6             -> z = 0
            {instruction[48],  instruction[49],  instruction[50],  instruction[51]}  <= `INSTRUCTION_LEN'b0001_00_0_0100_0_0001_0001_000000000001; // ADDNE R1,  R1, R1         -> R1 = 8192
            {instruction[52],  instruction[53],  instruction[54],  instruction[55]}  <= `INSTRUCTION_LEN'b1110_00_0_1000_1_1001_0000_000000001000; // TST   R9,  R8             -> z = 0
            {instruction[56],  instruction[57],  instruction[58],  instruction[59]}  <= `INSTRUCTION_LEN'b0000_00_0_0100_0_0010_0010_000000000010; // ADDEQ R2,  R2, R2         -> R2 = -1073741824
            {instruction[60],  instruction[61],  instruction[62],  instruction[63]}  <= `INSTRUCTION_LEN'b1110_00_1_1101_0_0000_0000_101100000001; // MOV   R0,  #1024          -> R0 = 1024
            {instruction[64],  instruction[65],  instruction[66],  instruction[67]}  <= `INSTRUCTION_LEN'b1110_01_0_0100_0_0000_0001_000000000000; // STR   R1,  [R0], #0       -> MEM[1024] = 8192
            {instruction[68],  instruction[69],  instruction[70],  instruction[71]}  <= `INSTRUCTION_LEN'b1110_01_0_0100_1_0000_1011_000000000000; // LDR   R11, [R0], #0       -> R11 = 8192
            {instruction[72],  instruction[73],  instruction[74],  instruction[75]}  <= `INSTRUCTION_LEN'b1110_01_0_0100_0_0000_0010_000000000100; // STR	  R2,  [R0], #4	      -> MEM[1028] = -1073741824
            {instruction[76],  instruction[77],  instruction[78],  instruction[79]}  <= `INSTRUCTION_LEN'b1110_01_0_0100_0_0000_0011_000000001000; // STR	  R3,  [R0], #8	      -> MEM[1032] = -2147483648
            {instruction[80],  instruction[81],  instruction[82],  instruction[83]}  <= `INSTRUCTION_LEN'b1110_01_0_0100_0_0000_0100_000000001101; // STR	  R4,  [R0], #13      -> MEM[1036] = 41
            {instruction[84],  instruction[85],  instruction[86],  instruction[87]}  <= `INSTRUCTION_LEN'b1110_01_0_0100_0_0000_0101_000000010000; // STR	  R5,  [R0], #16      -> MEM[1040] = -123
            {instruction[88],  instruction[89],  instruction[90],  instruction[91]}  <= `INSTRUCTION_LEN'b1110_01_0_0100_0_0000_0110_000000010100; // STR	  R6,  [R0], #20      -> MEM[1044] = 10
            {instruction[92],  instruction[93],  instruction[94],  instruction[95]}  <= `INSTRUCTION_LEN'b1110_01_0_0100_1_0000_1010_000000000100; // LDR	  R10, [R0], #4	      -> R10 = -1073741824
            {instruction[96],  instruction[97],  instruction[98],  instruction[99]}  <= `INSTRUCTION_LEN'b1110_01_0_0100_0_0000_0111_000000011000; // STR	  R7,  [R0], #24      -> MEM[1048] = -123
            {instruction[100], instruction[101], instruction[102], instruction[103]} <= `INSTRUCTION_LEN'b1110_00_1_1101_0_0000_0001_000000000100; // MOV	  R1,  #4             -> R1 = 4
            {instruction[104], instruction[105], instruction[106], instruction[107]} <= `INSTRUCTION_LEN'b1110_00_1_1101_0_0000_0010_000000000000; // MOV	  R2,  #0             -> R2 = 0
            {instruction[108], instruction[109], instruction[110], instruction[111]} <= `INSTRUCTION_LEN'b1110_00_1_1101_0_0000_0011_000000000000; // MOV	  R3,  #0             -> R3 = 0
            {instruction[112], instruction[113], instruction[114], instruction[115]} <= `INSTRUCTION_LEN'b1110_00_0_0100_0_0000_0100_000100000011; // ADD	  R4,  R0, R3, LSL #2 -> R4 = 1024
            {instruction[116], instruction[117], instruction[118], instruction[119]} <= `INSTRUCTION_LEN'b1110_01_0_0100_1_0100_0101_000000000000; // LDR	  R5,  [R4], #0       -> R5 = 8192
            {instruction[120], instruction[121], instruction[122], instruction[123]} <= `INSTRUCTION_LEN'b1110_01_0_0100_1_0100_0110_000000000100; // LDR	  R6,  [R4], #4       -> R6 = -1073741824
            {instruction[124], instruction[125], instruction[126], instruction[127]} <= `INSTRUCTION_LEN'b1110_00_0_1010_1_0101_0000_000000000110; // CMP	  R5,  R6             -> z = 0, n = 0, v = 0
            {instruction[128], instruction[129], instruction[130], instruction[131]} <= `INSTRUCTION_LEN'b1100_01_0_0100_0_0100_0110_000000000000; // STRGT R6,  [R4], #0         -> MEM[1024] = -1073741824
            {instruction[132], instruction[133], instruction[134], instruction[135]} <= `INSTRUCTION_LEN'b1100_01_0_0100_0_0100_0101_000000000100; // STRGT R5,  [R4], #4         -> MEM[1028] = 8192
            {instruction[136], instruction[137], instruction[138], instruction[139]} <= `INSTRUCTION_LEN'b1110_00_1_0100_0_0011_0011_000000000001; // ADD	  R3,  R3,   #1       -> R3 = 1
            {instruction[140], instruction[141], instruction[142], instruction[143]} <= `INSTRUCTION_LEN'b1110_00_1_1010_1_0011_0000_000000000011; // CMP	  R3,  #3             -> z = 0, n = 1, v = 0
            {instruction[144], instruction[145], instruction[146], instruction[147]} <= `INSTRUCTION_LEN'b1011_10_1_0_111111111111111111110111;    // BLT	  #-9                 -> PC = 32'd112
            {instruction[148], instruction[149], instruction[150], instruction[151]} <= `INSTRUCTION_LEN'b1110_00_1_0100_0_0010_0010_000000000001; // ADD	  R2,  R2,   #1       -> R2 = -2147483648
            {instruction[152], instruction[153], instruction[154], instruction[155]} <= `INSTRUCTION_LEN'b1110_00_0_1010_1_0010_0000_000000000001; // CMP	  R2,  R1             -> z = 0, n = 1, v = 0
            {instruction[156], instruction[157], instruction[158], instruction[159]} <= `INSTRUCTION_LEN'b1011_10_1_0_111111111111111111110011;    // BLT	  #-13                -> PC = 32'd112
            {instruction[160], instruction[161], instruction[162], instruction[163]} <= `INSTRUCTION_LEN'b1110_01_0_0100_1_0000_0001_000000000000; // LDR	  R1,  [R0], #0	      -> R1 = -2147483648
            {instruction[164], instruction[165], instruction[166], instruction[167]} <= `INSTRUCTION_LEN'b1110_01_0_0100_1_0000_0010_000000000100; // LDR	  R2,  [R0], #4	      -> R2 = -1073741824
            {instruction[168], instruction[169], instruction[170], instruction[171]} <= `INSTRUCTION_LEN'b1110_01_0_0100_1_0000_0011_000000001000; // LDR	  R3,  [R0], #8	      -> R3 = 41
            {instruction[172], instruction[173], instruction[174], instruction[175]} <= `INSTRUCTION_LEN'b1110_01_0_0100_1_0000_0100_000000001100; // LDR	  R4,  [R0], #12      -> R4 = 8192
            {instruction[176], instruction[177], instruction[178], instruction[179]} <= `INSTRUCTION_LEN'b1110_01_0_0100_1_0000_0101_000000010000; // LDR	  R5,  [R0], #16      -> R5 = -123
            {instruction[180], instruction[181], instruction[182], instruction[183]} <= `INSTRUCTION_LEN'b1110_01_0_0100_1_0000_0110_000000010100; // LDR	  R6,  [R0], #20      -> R4 = 10
            {instruction[184], instruction[185], instruction[186], instruction[187]} <= `INSTRUCTION_LEN'b1110_10_1_0_111111111111111111111111;    // B	  #-1                 -> PC = 32'd184 (infinite loop)
        end
    end

endmodule
