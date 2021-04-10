module cpu_top(
	input clk, rst_n, nextTransaction,
	input [1:0] Interrupt,
	output ack, en,
	output [31:0] memDataOut, memAddr //DMA FSM stuff (tbt)
);


//DMA FSM


//Forwarding Unit


//Fetch


//Decode
logic [31:0] RegData0, RegData1, imm, BrPC, SPOut;
logic ALU_A_SEL, Branch, MemInSel, memwr, memrd, WbDataSel, WbRegSel, SPwe_o, wEn, SPwe_in;
logic ALU_B_SEL;

decode dec_comb(.*);


//Execute
logic [31:0] exeOut, RegData1_o;
execute exe_comb(.RegData0(RegData0), .RegData1(RegData1), .SPOut(SPOut), .imm(imm), .opcode(inst[31:27]),
				.ALU_A_SEL(ALU_A_SEL), .ALU_B_SEL(ALU_B_SEL), .MemInSel(MemInSel), 
				.exeOut(exeOut), .RegData1_o(RegData1_o));

//Mem


//Writeback


endmodule

