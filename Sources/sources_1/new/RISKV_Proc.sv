module RISKV_Proc(
input logic CLK100MHZ,
input logic CPU_RESETN,

input                  [31:0] instr_rdata_i,
output  logic          [31:0]  instr_addr_o,

input  [31:0]                data_rdata_i,
output  logic                  data_req_o,
output  logic                  data_we_o,
output  logic          [3:0]   data_be_o,
output  logic          [31:0]  data_addr_o,
output  logic          [31:0]  data_wdata_o,

	// контроллер прерываний
	input ic_int_i,                // запрос на обработку прерывания от контроллера прерываний
	input [31:0] ic_mcause_i,      // номер прерывания
	output logic [31:0] ic_mie_o,  // маска прерываний
	output logic ic_int_rst_o      // сигнал о завершении обработки прерывания контроллеру
);

 logic [31:0]    PC; 
 logic [31:0] Instr;
 logic     Alu_Flag;
 logic [31:0]    WD3;
 logic [31:0]  Alu_Result;
 logic [31:0] A;
 logic [31:0] B;
 logic gpr_we_a_o;
 logic branch_o;
 logic jal_o;
 logic [1:0] jalr_o;
 logic [31:0] RD1;
 logic [31:0] RD2;
 logic [1:0] ex_op_a_sel_o;      
 logic [2:0] ex_op_b_sel_o;
 logic [4:0] alu_op_o;
 logic mem_we_o;
 logic [31:0] A_mem;
 logic [31:0] RD_mem;
 logic wb_src_sel_o;
 logic [2:0] mem_size;
 logic lsu_req_o;
 logic enable_pc;
 
 assign A_mem = Alu_Result;
 logic lsu_stall_req;
 
//новые для декодера 
logic[1:0] csr_op_o; //операции над регистрами
logic reg_file_wd_csr_o;
logic [31:0] RD_CSR;//в мультиплексор
logic [31:0] mtvec_mpx;// адрес начала обработчика прерываний
logic [31:0] mepc_mpx;
 
 


 
 
Register_file Rgf(
     .clk(CLK100MHZ),
     .WE3(gpr_we_a_o),       
     .A1(Instr[19:15]),
     .A2(Instr[24:20]),
     .A3(Instr[11:7]),
     .WD3(WD3),
     .RD1(RD1),
     .RD2(RD2)
);

Decoder Dec(
  .fetched_instr_i(Instr),
  .ex_op_a_sel_o(ex_op_a_sel_o),      
  .ex_op_b_sel_o(ex_op_b_sel_o),       
  .alu_op_o(alu_op_o),           
  .mem_req_o(lsu_req_o),           
  .mem_we_o(mem_we_o),                    
  .mem_size_o(mem_size),         
  .gpr_we_a_o(gpr_we_a_o),         
  .wb_src_sel_o(wb_src_sel_o),       
  .illegal_instr_o(),    
  .branch_o(branch_o),           
  .jal_o(jal_o),              
  .jalr_o(jalr_o),
  .mem_stall_req_i(lsu_stall_req),
  .enable_pc(enable_pc),  
  
.ic_int_i(ic_int_i),// запрос на обработку прерывания
.ic_int_rst_o(ic_int_rst_o), //сигнал о завершении обработки прерывания 
.csr_op_o(csr_op_o), //операции над регистрами
.reg_file_wd_csr_o(reg_file_wd_csr_o)	// Управляющий сигнал мультиплексора для выбора данных, записываемых в регистровый файл (модуль CSR)           
);

 
ALU aluops(
    .A(A),
    .B(B),
    .ALUOp(alu_op_o),
    .Flag(Alu_Flag),
    .Result(Alu_Result)
    );
    
Lsu lsu0(

.clk_i(CLK100MHZ), // синхронизация
.rstn(CPU_RESETN), // сброс внутренних регистров

// core protocol
.lsu_addr_i(Alu_Result), // адрес, по которому хотим обратиться
.lsu_we_i(mem_we_o), // 1 - если нужно записать в память
.lsu_size_i(mem_size), // размер обрабатываемых данных
.lsu_data_i(RD2), // данные для записи в память
.lsu_req_i(lsu_req_o), // 1 - обратиться к памяти
.lsu_stall_req_o(lsu_stall_req), // используется как !enable pc
.lsu_data_o(RD_mem), // данные считанные из памяти

// memory protocol
.data_rdata_i(data_rdata_i), // запрошенные данные
.data_req_o(data_req_o), // 1 - обратиться к памяти
.data_we_o(data_we_o), // 1 - это запрос на запись
.data_be_o(data_be_o), // к каким байтам слова идет обращение
.data_addr_o(data_addr_o), // адрес, по которому идет обращение
.data_wdata_o(data_wdata_o) // данные, которые требуется записать
);

csr csr0(
	
	// тактовый сигнал и сигнал сброса
.clk(CLK100MHZ),
.rstn(CPU_RESETN),
	
.IC_INT(ic_int_i), 		// сигнал о прерывании
.CSR_OP(csr_op_o),	// команда для блока CSR
.A(Instr[31:20]),		// номер регистра
.PC(PC),	// счётчик команд
.WD(RD1),	// данные для записи в регистры CSR
.RD(RD_CSR),	// считанные из регистров CSR данные
	
	// доступ к этим системным регистрам необходим для работы прерываний
.mcause_i(ic_mcause_i),	// номер прерывания
.mie_o(ic_mie_o),	// маска прерываний
.mtvec_o(mtvec_mpx),	// адрес начала обработчика прерываний
.mepc_o(mepc_mpx)	// здесь хранится значение счётчика команд до вызова обработчика прерываний 
	);
 

//константы

logic [31:0] imm_i;
assign imm_i = $signed({{20{Instr[31]}},Instr[31:20]});

logic [31:0] imm_Alu; 
assign imm_Alu = $signed({Instr[31:12],{12{1'b0}}});
 
logic [31:0] imm_s;
assign imm_s = $signed({{22{Instr[31]}},{Instr[31:25],Instr[11:7]}});

logic [31:0] imm_j;
assign imm_j = $signed({{12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0});

logic [31:0] imm_b;
assign imm_b = $signed({{20{Instr[31]}},Instr[7],Instr[30:25],Instr[11:8], 1'b0});

//PC
 always_ff@(posedge CLK100MHZ) begin
    if(~CPU_RESETN) 
        PC <= 0;
    else if(enable_pc) 
         case(jalr_o)
         2'b01: PC <= RD1 + imm_i;
         2'b00: begin case(jal_o|(Alu_Flag&branch_o)) 
                1'b0: PC <= PC + 4;
                1'b1:
                case(branch_o) 
                1'b0: PC <= $signed(PC) + imm_j;
                1'b1: PC <= PC + imm_b;
                endcase
                endcase
                end
         2'b10: PC <= mepc_mpx;
         2'b11: PC <= mtvec_mpx;
        endcase
end
 
 assign  Instr[31:0] = instr_rdata_i;
 assign instr_addr_o = PC;
 
//мультиплексор на а
always_comb begin
case(ex_op_a_sel_o) 
    2'd0: begin
             A = RD1;
          end        
    2'd1: begin 
            A = PC;
          end
    2'd2: begin 
            A = 0;
           end
        
     default: A = RD1;
        
     endcase
end

//мудьтиплексор на b
always_comb begin
case(ex_op_b_sel_o) 
    5'd0: begin
             B = RD2;
          end        
    5'd1: begin 
            B = imm_i;
          end
    5'd2: begin 
            B = imm_Alu;
           end
    5'd3: begin 
             B = imm_s;
           end
    5'd4: begin 
            B = 4;
           end
        
     default: B = 0;
        
     endcase
end

//мультиплексор на выходе из пзу
always_comb begin
case(wb_src_sel_o) 
    2'b0: begin
             WD3 = Alu_Result;
          end        
    2'b1: begin 
            WD3 = RD_mem;
          end
     default: WD3 = 0;
        
     endcase
end

endmodule
