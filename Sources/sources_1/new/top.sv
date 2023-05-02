//`timescale 1ns / 1ps



//module top(
//input logic CLK100MHZ,
//input logic CPU_RESETN,
//input logic [15:0]  SW,
//output logic [15:0] LED
//);

// logic [31:0]    PC; 
// logic [31:0] Instr;
// logic     Alu_Flag;
// logic         Flag;
// logic [31:0]    WD3;
// logic [31:0]  Alu_Result;
// logic [31:0] A;
// logic [31:0] B;
 
 
// ALU aluops (
//    .A(A),
//    .B(B),
//    .ALUOp(Instr[27:23]),
//    .Flag(Alu_Flag),
//    .Result(Alu_Result)
// );
 
// Register_file Rgf (
 
//     .clk(CLK100MHZ),
//     .WE3(Instr[28] | Instr[29]),       
//     .A1(Instr[22:18]),
//     .A2(Instr[17:13]),
//     .A3(Instr[4:0]),
//     .WD3(WD3),
//     .RD1(A),
//     .RD2(B)
//);
 
// Inst_Mem#(
//     .WIDTH(32),
//     .DEPTH(64)
//)Inst(
//    .A(PC),
//    .D(Instr)
 
// );
 
// assign Flag = (Alu_Flag & Instr[30])|Instr[31];
// assign LED[15:0] = A[15:0];
 
// always_ff@(posedge CLK100MHZ) 
//    begin
//    if(~CPU_RESETN) 
//        PC <= 0;
//    else if (Instr[31] || Instr[30] && Flag)
//        PC <= PC + $signed({{24{Instr[12]}},Instr[12:5]});
//    else
//        PC <= PC + 1;
//    end



//always_comb begin
//case(Instr[29:28]) 
//    2'd1: begin
//            WD3 = SW[15:0];
//          end        
//    2'd2: begin 
//            WD3 = $signed({{24{Instr[12]}},Instr[12:5]});
//          end
//     2'd3: begin 
//            WD3 = Alu_Result[31:0];
//           end
        
//     default: WD3=0;
        
//        endcase
//end

//endmodule

