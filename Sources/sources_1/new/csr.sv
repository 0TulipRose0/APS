/*Константы для операций над регистрами*/

`define CSR_OP_NOTHING 2'b00//нет команды
`define CSR_OP_CSRRW 2'b01// чтение/запись регистров
`define CSR_OP_CSRRS 2'b10 // чтение/установка регистров
`define CSR_OP_CSRRC 2'b11 // чтение/очистка регистров

/*Константы для адресов регистров*/

`define CSR_REG_MIE 12'h004
`define CSR_REG_MTVEC 12'h005
`define CSR_REG_MSCRATCH 12'h040
`define CSR_REG_MEPC 12'h041
`define CSR_REG_MCAUSE 12'h042


module csr(
	
	// тактовый сигнал и сигнал сброса
	input clk,
	input rstn,
	
	input IC_INT, 		// сигнал о прерывании
	input [1:0] CSR_OP,	// команда для блока CSR
	input [11:0] A,		// номер регистра
	input [31:0] PC,	// счётчик команд
	input [31:0] WD,	// данные для записи в регистры CSR
	output logic [31:0] RD,	// считанные из регистров CSR данные
	
	// доступ к этим системным регистрам необходим для работы прерываний
	input [31:0] mcause_i,	// номер прерывания
	output [31:0] mie_o,	// маска прерываний
	output [31:0] mtvec_o,	// адрес начала обработчика прерываний
	output [31:0] mepc_o	// здесь хранится значение счётчика команд до вызова обработчика прерываний 
	);
	
//регистры, которые нам нужны дляреализации is

logic [31:0] mie, mtvec, mscratch, mepc, mcause;

//установим регистры, с которых му будем читать
assign mie_o = mie;
assign mtvec_o = mtvec;
assign mepc_o = mepc;

//чтение с регистров

// Реализуем чтение системных регистров
	always_comb begin
		case (A)
			`CSR_REG_MIE: RD <= mie;
			`CSR_REG_MTVEC: RD <= mtvec;
			`CSR_REG_MSCRATCH: RD <= mscratch;
			`CSR_REG_MEPC: RD <= mepc;
			`CSR_REG_MCAUSE: RD <= mcause;
			default: RD <= 32'b0;
		endcase
	end

//обработаем операции над регистрами без учета сигнала о прерывании
logic csr_write_req;

assign csr_write_req = (CSR_OP == `CSR_OP_CSRRW) || (CSR_OP == `CSR_OP_CSRRS) || (CSR_OP == `CSR_OP_CSRRC);

logic [31:0] csr_new_data;
always_comb begin
    case(CSR_OP)

        `CSR_OP_CSRRW: csr_new_data <= WD;
        `CSR_OP_CSRRS: csr_new_data <= WD|RD;
        `CSR_OP_CSRRC: csr_new_data <= RD&(~WD);
        default: csr_new_data <= 32'b0;
    endcase
end

//синхронная запись в регистры
always_ff@(posedge clk) begin
    if(!rstn) begin
    //обнуление регистров
    mie      <= 32'b0;
    mtvec    <= 32'b0;
    mscratch <= 32'b0;
    end else    begin
                    if(csr_write_req)
                    case(A)
        			`CSR_REG_MIE: mie <= csr_new_data;
					`CSR_REG_MTVEC: mtvec <= csr_new_data;
					`CSR_REG_MSCRATCH: mscratch <= csr_new_data;
		            endcase
                end
end

//теперь реализуем запись в оставшиеся два регистра и тут уже учтём сигнал о прерывании
always_ff @(posedge clk) begin
    if(!rstn) begin
    mepc   <= 32'b0;
    mcause <= 32'b0;
    end else begin 
            if(IC_INT || A == `CSR_REG_MEPC && csr_write_req)
            mepc <= (IC_INT) ? PC : csr_new_data;
            if(IC_INT || A == `CSR_REG_MCAUSE && csr_write_req)
            mcause <= (IC_INT) ? mcause_i : csr_new_data; 
            end
end


endmodule