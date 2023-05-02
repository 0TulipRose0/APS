module Ps2(
    
    logic clk,
    logic rst,
    
    output logic int_req_o,
    input  logic int_fin_i
    );
    
    logic [9:0] cnt;
   
    always_ff@(posedge clk)
    begin
    if(!rst)
    cnt <= 0;
    else 
    
    cnt <= cnt + 1;
    
    end
    
    always_ff@(posedge clk)
    begin
    if(!rst||int_fin_i)
    int_req_o <= 0;
    else if(cnt == 31)
    int_req_o <= 1;
    end
    
endmodule
