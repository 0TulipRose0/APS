module miriscv_top
#(
  parameter RAM_SIZE      = 256, // bytes
  parameter RAM_INIT_FILE = "Int_Mem_Init.mem"
)(
  // clock, reset
  input clk_i,
  input rst_n_i
);

  logic  [31:0]  instr_rdata_core;
  logic  [31:0]  instr_addr_core;

  logic  [31:0]  data_rdata_core;
  logic          data_req_core;
  logic          data_we_core;
  logic  [3:0]   data_be_core;
  logic  [31:0]  data_addr_core;
  logic  [31:0]  data_wdata_core;

  logic  [31:0]  data_rdata_ram;
  logic          data_req_ram;
  logic          data_we_ram;
  logic  [3:0]   data_be_ram;
  logic  [31:0]  data_addr_ram;
  logic  [31:0]  data_wdata_ram;
  //Элементы, связанные с системой прерываний
  logic [31:0] mie;
  logic [31:0] mcause;
  logic ic_int;
  logic  ic_int_rst;
  
  logic [31:0]int_req_i;
  logic [31:0] int_fin_o;
  assign int_req_i[31:1] = 31'b0;
   
  
 
  logic  data_mem_valid;
  assign data_mem_valid = (data_addr_core >= RAM_SIZE) ?  1'b0 : 1'b1;

  assign data_rdata_core  = (data_mem_valid) ? data_rdata_ram : 1'b0;
  assign data_req_ram     = (data_mem_valid) ? data_req_core : 1'b0;
  assign data_we_ram      =  data_we_core;
  assign data_be_ram      =  data_be_core;
  assign data_addr_ram    =  data_addr_core;
  assign data_wdata_ram   =  data_wdata_core;

  RISKV_Proc core (
    .CLK100MHZ   ( clk_i   ),
    .CPU_RESETN ( rst_n_i ),

    .instr_rdata_i ( instr_rdata_core ),
    .instr_addr_o  ( instr_addr_core  ),

    .data_rdata_i  ( data_rdata_core  ),
    .data_req_o    ( data_req_core    ),
    .data_we_o     ( data_we_core     ),
    .data_be_o     ( data_be_core     ),
    .data_addr_o   ( data_addr_core   ),
    .data_wdata_o  ( data_wdata_core  ),
    
    // контроллер прерываний
	.ic_int_i(ic_int),                // запрос на обработку прерывания от контроллера прерываний
	.ic_mcause_i(mcause),      // номер прерывания
	.ic_mie_o(mie),  // маска прерываний
	.ic_int_rst_o(ic_int_rst)//сигнал о завершении обработки прерывания
  );

    Ps2 Pereferiya(
    .clk(clk_i),
    .rst(rst_n_i),
    
    .int_req_o(int_req_i[0]),
    .int_fin_i(int_fin_o[0])
);

  miriscv_ram
  #(
    .RAM_SIZE      (RAM_SIZE),
    .RAM_INIT_FILE (RAM_INIT_FILE)
  ) ram (
    .clk_i   ( clk_i   ),
    .rst_n_i ( rst_n_i ),

    .instr_rdata_o ( instr_rdata_core ),
    .instr_addr_i  ( instr_addr_core  ),

    .data_rdata_o  ( data_rdata_ram  ),
    .data_req_i    ( data_req_ram    ),
    .data_we_i     ( data_we_ram     ),
    .data_be_i     ( data_be_ram     ),
    .data_addr_i   ( data_addr_ram   ),
    .data_wdata_i  ( data_wdata_ram  )
  );
  
  is Inter_Sys
  (
  
  	// тактовый сигнал и сигнал сброса
	.clk(clk_i),
	.rstn(rst_n_i),
	
	// подключается к ядру процессора
	.mie_i(mie),		// маска прерываний
	.int_rst_i(ic_int_rst),		// сигнал о завершении обработки прерывания
	.int_o(ic_int),			// сигнал о наличии прерывания
	.mcause_o(mcause),	// номер прерывания
	
	// подключается к переферийным устройствам
	.int_req_i(int_req_i),    // запросы прерывания от устройств
	.int_fin_o(int_fin_)
  
  );


endmodule
