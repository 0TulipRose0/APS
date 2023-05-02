`timescale 1ns / 1ps



module ALU_TB();
logic [31:0] A;
logic [31:0] B;
logic [4:0] ALUOp;
logic Flag;
logic [31:0] Result;

import ALUops::*;

ALU aluinst(
    .A(A),
    .B(B),
    .ALUOp(ALUOp),
    .Flag(Flag),
    .Result(Result));
    
task alu_oper_task(
    input integer A_t,
    input integer B_t,
    input integer oper_tb,
    input integer Wait_arg
    );
  begin
    A = A_t;
    B = B_t;
    ALUOp = oper_tb;
    #10
    if(Wait_arg == Result) 
        $display("Good, wait %d and result %d", Wait_arg, Result);
    else 
        $display("Wait %d, but Result %d", Wait_arg, Result);
  end
endtask

initial begin 
      alu_oper_task(1,2,ADD_,3);
      #10
      alu_oper_task(3,1,AND_,1);
      #10
      alu_oper_task(4,2,OR_,1);
      #10 
      alu_oper_task(4,2,SUB_,1);
      #10
      alu_oper_task(3,3,BNE_,0);
      #10
      alu_oper_task(1,1,BNE_,0);
      #10
      alu_oper_task(0,1,BNE_,1);
end

endmodule