module Decoder(
  input       [31:0]   fetched_instr_i,
  output  reg [1:0]    ex_op_a_sel_o,      
  output  reg [2:0]    ex_op_b_sel_o,       
  output  reg [4:0]    alu_op_o,           
  output  reg          mem_req_o,           
  output  reg          mem_we_o,           
  output  reg [2:0]    mem_size_o,         
  output  reg          gpr_we_a_o,         
  output  reg          wb_src_sel_o,       
  output  reg          illegal_instr_o,    
  output  reg          branch_o,           
  output  reg          jal_o,              
  output  reg [1:0]    jalr_o, //изменено: увеличина разбитовка
  
 input                 mem_stall_req_i, //запрос о необходимости остановки процессора     
 output   logic        enable_pc,  // сигнал на программ каунтер дл€ его остановки 
 
 //блок дл€ работы с системой прерываний
 
 input                  ic_int_i,// запрос на обработку прерывани€
 output   logic         ic_int_rst_o, //сигнал о завершении обработки прерывани€ 
 output   logic [1:0]   csr_op_o, //операции над регистрами
 
 output   logic         reg_file_wd_csr_o	// ”правл€ющий сигнал мультиплексора дл€ выбора данных, записываемых в регистровый файл (модуль CSR)
);

assign enable_pc = !mem_stall_req_i || ic_int_i; //приостановка, когда данные поступили в пам€ть

logic reg_file_we; //запись в регистровый файл возможна только тогда, когда процессор не приостановлен
assign gpr_we_a_o = reg_file_we & enable_pc & !ic_int_i;

//это флаг при работе с ситемой    
logic system;
assign system = (fetched_instr_i[6:0] == 7'b1110011) || ic_int_i;
assign ic_int_rst_o = fetched_instr_i == 32'b00110000001000000000000001110011;



    logic jalr; //флаг
    assign jalr = (fetched_instr_i[6:0] == 7'b1100111) && (!illegal_instr_o);
    /* »сточник записи в счЄтчик команд */
	logic [1:0] system_pc_src_sel;
	always_comb begin
		if (fetched_instr_i == 32'b00110000001000000000000001110011) system_pc_src_sel = 2'd2;
		else if (ic_int_i) system_pc_src_sel = 2'd3;
		else system_pc_src_sel = 2'd0;
	end
	
	// ќбработка системных инструкций
	logic csr_instruction;
	assign csr_op_o = (csr_instruction) ? fetched_instr_i[13:12] : 2'b0;
	assign reg_file_wd_csr_o = (!system) ? 0 : csr_instruction;

always_comb begin
 if(ic_int_i)
 begin
                illegal_instr_o = 0;
                ex_op_a_sel_o = 0;
                ex_op_b_sel_o = 0;
                mem_req_o = 0;
                mem_we_o = 0;
                mem_size_o = 0;
                reg_file_we = 0;
                wb_src_sel_o = 0;
                jalr_o = 2'b11;              
                illegal_instr_o = 0;
                branch_o = 0;
                alu_op_o = 0;
                csr_op_o = 0;
                jal_o = 0;
 end
 else
    case(fetched_instr_i[6:0])
    
   
    7'b0110011: begin // alu 
                ex_op_a_sel_o = 0;
                ex_op_b_sel_o = 0;
                mem_req_o = 0;
                mem_we_o = 0;
                mem_size_o = 0;
                reg_file_we = 1;
                wb_src_sel_o = 0;
                jal_o = 0;              
                illegal_instr_o = 0;
                branch_o = 0;
                csr_op_o = 0;
                jalr_o = 0;
                
                
                
                case ({fetched_instr_i[31:25],fetched_instr_i[14:12]})
                    { 7'h20, 3'h0 }: begin
                            alu_op_o = 5'b01000;
                            end
                    { 7'h00, 3'h0 }: begin
                            alu_op_o = 5'b00000;
                            end
                    { 7'h00, 3'h4 }: begin
                            alu_op_o = 5'b00100;
                            end
                    { 7'h00, 3'h6 }: begin
                            alu_op_o = 5'b00110;
                            end
                    { 7'h00, 3'h7 }: begin
                            alu_op_o = 5'b00111;
                            end
                    { 7'h00, 3'h1 }: begin
                            alu_op_o = 5'b00001;
                            end
                    { 7'h00, 3'h5 }: begin
                            alu_op_o = 5'b00101;
                            end
                    { 7'h20, 3'h5 }: begin
                            alu_op_o = 5'b01101;
                            end
                    { 7'h00, 3'h2 }: begin
                            alu_op_o = 5'b00010;
                            end
                    { 7'h00, 3'h3 }: begin
                            alu_op_o = 5'b00011;
                            end
                    default: begin
                    alu_op_o = 0;
                    illegal_instr_o = 1;
                    end
                endcase
                end
    
    7'b0010011: begin //alu с константами
                ex_op_a_sel_o = 0;
                ex_op_b_sel_o = 1;
                mem_req_o = 0;
                mem_we_o = 0;
                mem_size_o = 0;
                reg_file_we = 1;
                wb_src_sel_o = 0;
                jal_o = 0;              
                illegal_instr_o = 0;
                branch_o = 0;
                csr_op_o = 0;
                jalr_o = 0;
                
                case(fetched_instr_i[14:12])
                      3'h0: begin
                            alu_op_o = 5'b00000;
                            end
                      3'h4: begin
                            alu_op_o = 5'b00100;
                            end
                      3'h6: begin
                            alu_op_o = 5'b00110;
                            end
                      3'h7: begin
                            alu_op_o = 5'b00111;
                            end
                     3'h1: begin
                            if( fetched_instr_i[31:25] == 7'h0)
                            alu_op_o = 5'b00001;
                            else begin 
                                illegal_instr_o = 1;
                                alu_op_o = 0;
                                 end
                            end
                    3'h5: begin
                            if(  fetched_instr_i[31:25] == 7'h0)
                            alu_op_o = 5'b00101;
                            else if(fetched_instr_i[31:25] == 7'h20)
                            alu_op_o = 5'b01101;
                            else alu_op_o = 0;
                                 illegal_instr_o = 1;
                            end
                      3'h2: begin
                            alu_op_o = 5'b00010;
                            end
                      3'h3: begin
                            alu_op_o = 5'b00011;
                            end
                      default: begin
                               alu_op_o = 0;
                               illegal_instr_o = 1;
                               end
                endcase
                end
                
        7'b0110111: begin //load upper immediate
                ex_op_a_sel_o = 2;
                ex_op_b_sel_o = 2;
                mem_req_o = 0;
                mem_we_o = 0;
                mem_size_o = 0;
                reg_file_we = 1;
                wb_src_sel_o = 0;
                jal_o = 0;              
                alu_op_o = 0;
                illegal_instr_o = 0;
                branch_o = 0;
                csr_op_o = 0;   
                jalr_o = 0; 
                end
                    
         7'b0000011:begin //load word
                mem_we_o = 0;
                ex_op_a_sel_o = 0;
                ex_op_b_sel_o = 1;
                mem_req_o = 1;
                reg_file_we = 1;
                wb_src_sel_o = 1;
                jal_o = 0;              
                alu_op_o = 0;
                illegal_instr_o = 0;
                branch_o = 0;
                csr_op_o = 0;
                jalr_o = 0;
                mem_req_o = 1;
                
                case(fetched_instr_i[14:12])
                3'h0: mem_size_o = 3'd0;
                3'h1: mem_size_o = 3'd1;
                3'h2: mem_size_o = 3'd2;
                3'h4: mem_size_o = 3'd4;
                3'h5: mem_size_o = 3'd5;
                default:  begin
                mem_size_o = 0;
                illegal_instr_o = 1;
                          end
                endcase

                            
                end
           
           7'b0100011:begin //store word
                      mem_we_o = 1;
                      ex_op_a_sel_o = 0;
                      ex_op_b_sel_o = 3;
                      mem_req_o = 1;
                      reg_file_we = 0;
                      wb_src_sel_o = 0;
                      jal_o = 0;              
                      alu_op_o = 0;
                      illegal_instr_o = 0;
                      branch_o = 0;
                      csr_op_o = 0;
                      jalr_o = 0;
                      mem_req_o = 1;
                      
                      case(fetched_instr_i[14:12])
                      3'h0: mem_size_o = 3'd0;
                      3'h1: mem_size_o = 3'd1;
                      3'h2: mem_size_o = 3'd2;
                      default: begin
                      illegal_instr_o = 1;
                      mem_size_o = 0;
                      end
                      endcase

                
                      end
                      
            7'b1100011:begin//условные переходы
                      ex_op_a_sel_o = 0;
                      ex_op_b_sel_o = 0;
                      mem_req_o = 0;
                      mem_we_o = 0;
                      mem_size_o = 0;
                      reg_file_we = 0;
                      wb_src_sel_o = 0;
                      jal_o = 0;              
                      illegal_instr_o = 0;
                      branch_o = 1;
                      csr_op_o = 0;
                      jalr_o = 0;
                      
                      
                      case(fetched_instr_i[14:12])
                      3'h0: alu_op_o = 5'b1_1_000;
                      3'h1: alu_op_o = 5'b1_1_001;
                      3'h4: alu_op_o = 5'b1_1_100;
                      3'h5: alu_op_o = 5'b1_1_101;
                      3'h6: alu_op_o = 5'b1_1_110;
                      3'h7: alu_op_o = 5'b1_1_111;
                      default:   begin
                                alu_op_o = 0;
                                illegal_instr_o = 1;
                                end
                      endcase
                      end
                      
            7'b1101111:begin //jal
                        ex_op_a_sel_o = 1;
                        ex_op_b_sel_o = 4;
                        mem_req_o = 0;
                        mem_we_o = 0;
                        mem_size_o = 0;
                        reg_file_we = 1;
                        wb_src_sel_o = 0;
                        jal_o = 1;
                        jalr_o = 0;              
                        alu_op_o = 0;
                        illegal_instr_o = 0;
                        branch_o = 0;
                        csr_op_o = 0;
                       
                       end
                       
            7'b1100111:begin //jalr    
                        if(fetched_instr_i[14:12]==0) begin
                        ex_op_a_sel_o = 1;
                        ex_op_b_sel_o = 4;
                        mem_req_o = 0;
                        mem_we_o = 1;
                        mem_size_o = 0;
                        reg_file_we = 1;
                        wb_src_sel_o = 0;
                        jal_o = 0;              
                        alu_op_o = 0;
                        illegal_instr_o = 0;
                        branch_o = 0;
                        csr_op_o = 0; 
                        jalr_o = 1;
                        
                        end else begin 
                                illegal_instr_o = 1;           
                                ex_op_a_sel_o = 0;
                                ex_op_b_sel_o = 0;
                                mem_req_o = 0;
                                mem_we_o = 0;
                                mem_size_o = 0;
                                reg_file_we = 0;
                                wb_src_sel_o = 0;
                                jal_o = 0;              
                                alu_op_o = 0;
                                branch_o = 0;
                                jalr_o = 1;
                                end
                       end
                       
                       
           7'b0010111:begin //auipc
                        jalr_o = 0;
                        ex_op_a_sel_o = 1;
                        ex_op_b_sel_o = 2;
                        mem_req_o = 0;
                        mem_we_o = 0;
                        mem_size_o = 0;
                        reg_file_we = 1;
                        wb_src_sel_o = 0;
                        jal_o = 0;              
                        alu_op_o = 0;
                        illegal_instr_o = 0;
                        branch_o = 0;
                        csr_op_o = 0;
                        jalr_o = 0;
                      end    
                       
             7'b1110011:begin

                        ex_op_a_sel_o = 0;
                        ex_op_b_sel_o = 0;
                        alu_op_o = 0;
                        illegal_instr_o = 0;
                        
                        case(fetched_instr_i[14:12]) 
                            3'b001,3'b010,3'b011: begin
                                csr_instruction = 1;
                                reg_file_we = 1;
                                wb_src_sel_o = 0;
                                jalr_o = 0;
                            end
                            3'b000: begin
                                jalr_o = 2;
                                csr_instruction = 0;
                                reg_file_we = 0;
                                wb_src_sel_o = 0;
                            end
                        endcase
                        
                        mem_req_o = 0;
                        mem_we_o = 0;
                        mem_size_o = 0;
                        jal_o = 0;              
                        branch_o = 0;
                       end  
                      
           default:     begin
                        jalr_o = 0;
                        ex_op_a_sel_o = 0;
                        ex_op_b_sel_o = 0;
                        mem_req_o = 0;
                        mem_we_o = 0;
                        mem_size_o = 0;
                        reg_file_we = 0;
                        wb_src_sel_o = 0;
                        jal_o = 0;              
                        alu_op_o = 0;
                        branch_o = 0;
                        
                        illegal_instr_o = 1;
                        
                        end
    endcase
end

endmodule
