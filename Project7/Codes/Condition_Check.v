module Condition_Check(cond, status_register, condition);
    input  [3:0] cond, status_register;
    output condition;
    reg   condition_state;
    assign {Z, C, N, V} = status_register;

    parameter [3:0] EQ = 4'b0000,
                    NE = 4'b0001,
                    CS_HS = 4'b0010,
                    CC_LO = 4'b0011,
                    MI = 4'b0100,
                    PL = 4'b0101,
                    VS = 4'b0110,
                    VC = 4'b0111,
                    HI = 4'b1000,
                    LS = 4'b1001,
                    GE = 4'b1010,
                    LT = 4'b1011,
                    GT = 4'b1100,
                    LE = 4'b1101,
                    AL = 4'b1110;

    always @(cond, Z, C, N, V)begin
        // condition_state = 1'b0;
        case(cond)
            EQ:    condition_state = Z;
            NE:    condition_state = ~Z;
            CS_HS: condition_state = C;
            CC_LO: condition_state = ~C;
            MI:    condition_state = N;
            PL:    condition_state = ~N;
            VS:    condition_state = V;
            VC:    condition_state = ~V;
            HI:    condition_state = C & ~Z;
            LS:    condition_state = ~C | Z;
            GE:    condition_state = (N & V) | (~N & ~V);
            LT:    condition_state = N != V;
            GT:    condition_state = ~Z & ((N & V) | (~N & ~V));
            LE:    condition_state = Z | ((N & ~V) | (~N & V));
            AL:    condition_state = 1'b1;
            default: condition_state = 1'b0;
        endcase
    end
    assign condition = condition_state;
endmodule