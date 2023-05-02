`timescale 1ns / 1ps

module Proc_TB( );
    
logic clk;
logic rst;
logic [15:0] out;
logic [15:0] in;

parameter PERIOD = 10;
initial forever begin
      #(PERIOD/2) clk = 1'b1;
      #(PERIOD/2) clk = 1'b0;
end


top dut(
    .CLK100MHZ(clk),
    .CPU_RESETN(rst),
    .LED(out),
    .SW(in)
);


initial begin
    in = 5;
    rst = 0;
    #100;
    rst = 1;
end

    
endmodule
