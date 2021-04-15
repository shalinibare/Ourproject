module cpu_top(
	input clk, rst_n, nextTransaction,
	input [1:0] Interrupt,
	output ack, en, halt,
	output [31:0] memDataOut, memAddr //DMA FSM stuff (tbt)
);

logic [31:0] RegData0, RegData1, imm, BrPC, SPOut, SPin, exeOut, wData;
logic [31:0] PC, inst, LastPC;
logic [31:0] RegData1_o;
logic [31:0] Addr, MemDataIn, MemOut;
logic [31:0] WbData;
logic [4:0] Rx, LR, WbReg;
logic valid;
logic Branch, MemInSel, memwr, memrd, WbRegSel, SPwe_o, wEn, wEn_o, SPwe_in;
logic [4:0] wReg;
logic [1:0] WbDataSel, ALU_A_SEL, ALU_B_SEL;

//DMA FSM
assign memDataOut = 32'h0;
assign memAddr = 32'h0;
assign en = 1'b0;

//Forwarding Unit (pipelined)


//Interrupt stuff
assign ack = 1'b0;


//Fetch
fetch fetch_stage(.*);

//F_D Pipeline

//Decode

assign wEn = wEn_o;
assign SPwe_in = SPwe_o;
assign SPin = exeOut;
assign wReg = WbReg;
assign wData = WbData;
decode dec_stage(.*);

//D_X Pipeline

//Execute
execute exe_stage(.RegData0(RegData0), .RegData1(RegData1), .SPOut(SPOut), .imm(imm), .opcode(inst[31:27]),
				.ALU_A_SEL(ALU_A_SEL), .ALU_B_SEL(ALU_B_SEL), .MemInSel(MemInSel), 
				.exeOut(exeOut), .RegData1_o(RegData1_o));

//X_M Pipeline

//Mem

assign Addr = exeOut;
assign MemDataIn = RegData1_o;
memory mem_stage(.*);

//M_W Pipeline

//Writeback

wb wb_stage(.*);

assign halt = &inst[31:27];

endmodule

