module Lsu(
input clk_i, // синхронизаци€
input rstn, // сброс внутренних регистров

// core protocol
input logic [31:0] lsu_addr_i, // адрес, по которому хотим обратитьс€
input logic lsu_we_i, // 1 - если нужно записать в пам€ть
input logic [2:0] lsu_size_i, // размер обрабатываемых данных
input logic [31:0] lsu_data_i, // данные дл€ записи в пам€ть
input logic lsu_req_i, // 1 - обратитьс€ к пам€ти
output logic lsu_stall_req_o, // используетс€ как !enable pc
output logic [31:0] lsu_data_o, // данные считанные из пам€ти

// memory protocol
input  logic [31:0] data_rdata_i, // запрошенные данные
output logic data_req_o, // 1 - обратитьс€ к пам€ти
output logic data_we_o, // 1 - это запрос на запись
output logic [3:0] data_be_o, // к каким байтам слова идет обращение
output logic [31:0] data_addr_o, // адрес, по которому идет обращение
output logic [31:0] data_wdata_o // данные, которые требуетс€ записать
);

//объединЄнные порты
assign data_addr_o = lsu_addr_i;

assign  data_req_o = lsu_req_i ;

assign data_we_o = lsu_req_i && lsu_we_i;


always_comb begin
data_be_o = 0;
case(lsu_size_i) 
   3'b000,3'b100:      
    begin
           data_wdata_o <= { 4{lsu_data_i[7:0]} };
           case(lsu_addr_i[1:0])
           2'b00: data_be_o = 4'b0001;
           2'b01: data_be_o = 4'b0010;
           2'b10: data_be_o = 4'b0100;
           2'b11: data_be_o = 4'b1000;
           endcase
    end
   3'b001,3'b101:
   begin
            data_wdata_o <= { 2{lsu_data_i[15:0]} };     
            case(lsu_addr_i[1:0])
            2'b00: data_be_o = 4'b0011;
            2'b10: data_be_o = 4'b1100;
            endcase  
    end
   3'b010: 
   begin
           data_wdata_o <= lsu_data_i;
           data_be_o = 4'b1111;
    end
endcase
end

 

//always_comb begin    
// if (lsu_size_i== 3'b000 || lsu_size_i== 3'b100) 
//begin   
//    data_wdata_o <= { 4{lsu_data_i[7:0]} }; 
            
//    data_be_o <= 4'b0001;
    
//end else 
//    if (lsu_size_i==3'b001 || lsu_size_i==3'b101)  begin
            
//    data_wdata_o <= { 2{lsu_data_i[15:0]} };
            
//    data_be_o <= 4'b0011;
        
//end else begin
            
//    data_wdata_o <= lsu_data_i;
            
//    data_be_o <= 4'b1111;        
//end
//end

//always_comb begin
//lsu_data_o = 0;
//case(lsu_size_i) 
//   3'b000:      
//           case(lsu_addr_i[1:0])
//           2'b00: lsu_data_o = {24'b0,data_rdata_i[7:0]};
//           2'b01: lsu_data_o = {24'b0,data_rdata_i[15:8]};
//           2'b10: data_be_o = 4'b0100;
//           2'b11: data_be_o = 4'b1000;
//           endcase
//   3'b001,3'b101:     
//            case(lsu_addr_i[1:0])
//            2'b00: data_be_o = 4'b0011;
//            2'b10: data_be_o = 4'b1100;
//            endcase  
//   3'b010: data_be_o = 4'b1111;
   
//endcase
//end

	// ѕолучаем байт по нужному смещению (будет использоватьс€, если запрашивалс€ байт)
	logic [7:0] lb_data;
	always_comb begin
		case (lsu_addr_i[1:0])
			2'b00: lb_data <= data_rdata_i[7:0];
			2'b01: lb_data <= data_rdata_i[15:8];
			2'b10: lb_data <= data_rdata_i[23:16];
			2'b11: lb_data <= data_rdata_i[31:24];
		endcase
	end
	
	// ѕолучаем полуслово по нужному смещению (будет использоватьс€, если запрашивалось слово)
	logic [15:0] lh_data;
	assign lh_data = (lsu_addr_i[1:0] == 2'b10) ? data_rdata_i[31:16] : data_rdata_i[15:0];
	
	
	// „тение из пам€ти
	always_comb begin
		case (lsu_size_i)
            3'b000: lsu_data_o <= {{24{lb_data[7]}}, lb_data};
            3'b001: lsu_data_o <= {{16{lh_data[15]}}, lh_data};
            3'b100: lsu_data_o <= {24'b0, lb_data};
            3'b101: lsu_data_o <= {16'b0, lh_data};
            default: lsu_data_o <= data_rdata_i;
		endcase
	end
	
	// –еализуем синхронное чтение / запись данных
	
	logic data_need_req;
	assign data_need_req = lsu_req_i;
	logic mem_op_idle;
	always_ff @(posedge clk_i) begin
	    if (!rstn || !data_need_req) begin
	       mem_op_idle <= 1'b0;
	    end else begin
	       mem_op_idle <= !mem_op_idle;
	    end
	end
	assign data_req_o = data_need_req ^ mem_op_idle;
	
	// ѕриостанавлиаем процессор, пока идЄт обращение к ќ«”
	assign lsu_stall_req_o = data_req_o;
	
endmodule

