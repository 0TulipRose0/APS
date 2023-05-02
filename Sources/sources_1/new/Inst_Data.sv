// Ïאלÿעü ןנמדנאלל (ÏÇÓ)
module inst_Data #(parameter ROM_FILE="Int_Mem_Init.mem", parameter ROM_SIZE=1024) (A, RD);
   input [31:0] A;
   output logic [31:0] RD;
   
   reg [31:0] ROM [0:ROM_SIZE/4-1];
   
   always_comb begin
        if (A < ROM_SIZE/4)
            RD <= ROM[A >> 2];
        else
            RD <= 32'd0;
   end
   
   initial begin
        for (int i=0; i<ROM_SIZE/4; i++)
            ROM[i] = 32'b0;
        $readmemh(ROM_FILE, ROM);
   end
    
endmodule
