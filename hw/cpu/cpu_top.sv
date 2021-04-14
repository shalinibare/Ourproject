module cpu_top(
	input clk, rst_n, nextTransaction,
	input [1:0] Interrupt,
	output ack, en, hlt,
	output [31:0] memDataOut, memAddr //DMA FSM stuff (tbt)
);


//DMA FSM
assign memDataOut = 32'h0;
assign memAddr = 32'h0;
assign en = 1'b0;

//Forwarding Unit (pipelined)


//Interrupt stuff
assign ack = 1'b0;


//Fetch
logic [31:0] PC, inst;
fetch fetch_stage(.*);


//Decode
logic [31:0] RegData0, RegData1, imm, BrPC, SPOut;
logic ALU_A_SEL, Branch, MemInSel, memwr, memrd, WbDataSel, WbRegSel, SPwe_o, wEn, SPwe_in;
logic ALU_B_SEL;

decode dec_stage(.*);


//Execute
logic [31:0] exeOut, RegData1_o;
execute exe_stage(.RegData0(RegData0), .RegData1(RegData1), .SPOut(SPOut), .imm(imm), .opcode(inst[31:27]),
				.ALU_A_SEL(ALU_A_SEL), .ALU_B_SEL(ALU_B_SEL), .MemInSel(MemInSel), 
				.exeOut(exeOut), .RegData1_o(RegData1_o));

//Mem
memory mem_stage(.*);

//Writeback
wb wb_stage(.*);

assign hlt = &inst[31:27];

endmodule

