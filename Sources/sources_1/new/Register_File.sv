//`timescale 1ns / 1ps

module Register_file(
    input            clk,
    input            WE3,       
    input  [4:0]       A1,
    input  [4:0]       A2,
    input  [4:0]       A3,
    input  [31:0]     WD3,
    output [31:0]     RD1,
    output [31:0]     RD2
    );
    
logic[31:0] RAM [0:31];

assign RD1 = (A1 == 0) ? 32'b0 : RAM[A1];
assign RD2 = (A2 == 0) ? 32'b0 : RAM[A2];

//assign RD1 = RAM[A1];
//assign RD2 = RAM[A2];
//assign RAM[0] = 32'b0;

always_ff @(posedge clk) begin
        if(WE3) RAM[A3] <= WD3;
    end
endmodule
