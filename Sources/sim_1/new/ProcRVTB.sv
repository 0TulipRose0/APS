`timescale 1ns / 1ps

module ProcRVTB();

logic clk;
logic rst;

parameter PERIOD = 10;
initial forever begin 
#(PERIOD/2) clk = 1'b1;
#(PERIOD/2) clk = 1'b0;
end

RISKV_Proc dut (
.CLK100MHZ(clk),
.CPU_RESETN(rst)
);

initial begin 
rst = 0;
#100

rst = 1;
end

endmodule
