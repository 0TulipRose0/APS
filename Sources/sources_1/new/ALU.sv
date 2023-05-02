`timescale 1ns / 1ps

package ALUops;
    enum logic [4:0] {
    ADD_ = 5'b0_0_000,
    SUB_ = 5'b0_1_000,
    SLL_ = 5'b0_0_001,
    SLT_ = 5'b0_0_010,
    SLTU_ = 5'b0_0_011,
    XOR_ = 5'b0_0_100,
    SRL_ = 5'b0_0_101,
    SRA_ = 5'b0_1_101,
    OR_ = 5'b0_0_110,
    AND_ = 5'b0_0_111,
    BEQ_ = 5'b1_1_000,
    BNE_ = 5'b1_1_001,
    BLT_ = 5'b1_1_100,
    BGE_ = 5'b1_1_101,
    BLTU_ = 5'b1_1_110,
    BGEU_ = 5'b1_1_111
    } ALOop;
endpackage
        
module ALU
    import ALUops::*;
(
    input       [31:0]  A,
    input       [31:0]  B,
    input       [4:0]   ALUOp,
    output logic          Flag,
    output logic  [31:0]  Result
);
 



always_comb begin : ALU 
    case(ALUOp[4:0])
        ADD_ : begin
            Result = A + B ;
            Flag = 0;
        end
        SUB_ : begin 
            Result = A - B;
            Flag = 0;
        end
        SLL_ : begin 
            Result = A<<B;
            Flag = 0;
        end
        SLT_ : begin 
            Result = $signed(A)<$signed(B);
            Flag = 0;
        end
        SLTU_ : begin 
            Result = A < B;
            Flag = 0;
        end
        XOR_ : begin 
            Result = A^B;
            Flag = 0;
        end
        SRL_ : begin 
            Result = A>>B;
            Flag = 0;
        end
        SRA_ : begin 
            Result = $signed(A) >>> B;
            Flag = 0;
        end
        OR_ : begin 
            Result = A | B;
            Flag = 0;
        end
        AND_ : begin 
            Result = A & B;
            Flag = 0;
        end
        BEQ_ : begin 
            Result = 0;
            Flag = (A==B);
        end
        BNE_ : begin 
            Result = 0;
            Flag = (A!=B);
        end
        BLT_ : begin 
            Result = 0;
            Flag = $signed(A)<$signed(B);
        end
        BGE_ : begin 
            Result = 0;
            Flag = $signed(A)>= $signed(B);
        end
        BLTU_ : begin 
            Result = 0;
            Flag = (A<B);
        end
        BGEU_ : begin 
            Result = 0;
            Flag = (A>=B);
        end
        default: 
        begin
         Result=0;
         Flag=0; 
        end
    endcase
end
endmodule