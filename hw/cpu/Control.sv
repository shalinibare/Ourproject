//Version 0.1
module Control(
  input[4:0] opcode,
  output Reg1Sel, wEn, ALU_A_SEL, ALU_B_SEL, B, BEQ, JMP, RET, MemInSel, memwr, WbRegSel, SPwe, memrd,
  output[1:0] Reg0Sel, imm_sel, WbDataSel
);

assign Reg1Sel = memrd | memwr; //Rx for memory operations
assign wEn = (opcode[4:3] == 2'b00) | (opcode[3:1] == 3'b100) | 
			(opcode[3:1] == 3'b110) | (opcode == 5'b10000); //Reg file write enable
assign ALU_A_SEL = (opcode == 5'b01111) | (opcode == 5'b10000); //PUSH and POP
//Determine if ALU input is immediate
assign ALU_B_SEL = (opcode == 5'b00001) | (opcode == 5'b00010) |
				(opcode[4:1] == 4'b0010) | (opcode == 5'b00110) |
				(opcode[4:2] == 3'b011) | (opcode == 5'b10000);

assign B = opcode == 5'b10001;
assign BEQ = opcode == 5'b10010;
assign JMP = (opcode == 5'b10011) | (opcode == 5'b10100); //JMP and FUN
assign RET = (opcode == 5'b10100) | (opcode == 5'b10100); //RET and INTR

assign MemInSel = (opcode == 5'b01111); //Memory address select PUSH
assign memrd = (opcode == 5'b10000) | (opcode == 5'b01101); //mem read enable
assign memwr = (opcode == 5'b01111) | (opcode == 5'b01110); //PUSH and ST

assign WbDataSel = (opcode[4:3] == 2'b00) | (opcode[4:1] == 4'b0100) | 
					(opcode == 5'b01100) ? (2'b00) : //ALU operations
					//Memory Loads
					(opcode == 5'b01101) | (opcode == 5'b10000) ? (2'b01) :
					(2'b10); //Link Register
assign WbRegSel = (opcode == 5'b10100); //Rx or Link register write

assign SPwe = (opcode == 5'b01111) | (opcode == 5'b10000); //PUSH and POP
assign Reg0Sel = (opcode == 5'b10101) ? (2'b10) : //LR
				(opcode == 5'b10110) ? (2'b11) : //ILR
				(2'b01); //Ry
assign imm_sel = (opcode == 5'b10011) | (opcode == 5'b10100) ? (2'b10) :
					(opcode == 5'b01100) ? (2'b01) : (2'b00);

endmodule

