//Version 0.1
module Control(
  input[4:0] opcode,
  output Reg1Sel, wEn, ALU_A_SEL, ALU_B_SEL, B, BEQ, JMP, MemInSel, memwr, WbDataSel, WbRegSel, SPwe,
  output[1:0] Reg0Sel, imm_sel
);

//assign Reg1Sel = ; #Determine Register read input
//assign wEn = ; #Determine Register File enable
assign ALU_A_SEL = (opcode == 5'b01111) | (opcode == 5'b10000); 
//assign ALU_B_SEL = Determine if immediate input
assign B = opcode == 5'b10001;
assign BEQ = opcode == 5'b10010;
assign JMP = (opcode == 5'b10011);// | (opcode == 5'b10100); //JMP and FUN
//assign MemInSel = ;
//assign memwr
//assign WbDataSel
//assign WbRegSel
//assign SPwe = ;
//assign Reg0Sel = ;
//assign imm_sel = ;


endmodule

