module Data#(
    int WIDTH = 32,
    int DEPTH = 256
)(
    input                    clk,
    input                     WE, 
    input  [WIDTH-1:0]         A,
    input  [WIDTH-1:0]        WD,
    output logic [WIDTH-1:0]  RD
    );
    
logic[WIDTH-1:0] RAM [0:DEPTH-1];

always_ff @(posedge clk) begin
        if(WE) RAM[A[9:2]] <= WD;
    end
always_comb begin
        if(A[31:2]>=DEPTH) 
         RD = 0;                           
         else RD = RAM[A[9:2]];
end
endmodule

