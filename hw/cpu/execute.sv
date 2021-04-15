module execute(
  input[31:0] RegData0, RegData1, SPOut, imm, PC,
  input[4:0] opcode,
  input ALU_A_SEL, MemInSel,
  input [1:0] ALU_B_SEL,
  output [31:0] exeOut, RegData1_o
);

//Instantiate modules//
//Determine inputs
logic [31:0] ALU_A_in, ALU_B_in, ALUOut;
assign ALU_A_in = (ALU_A_SEL == 2'b00) ? RegData0 : 
					(ALU_A_SEL == 2'b01) ? SPOut : PC;
assign ALU_B_in = (ALU_B_SEL == 2'b00) ? RegData1 : 
				(ALU_B_SEL == 2'b01) ? imm : 32'h00000004;

//ALU
alu ALU(.*);

//Determine outputs
assign exeOut = MemInSel ? SPOut : ALUOut;
assign RegData1_o = RegData1;

endmodule

