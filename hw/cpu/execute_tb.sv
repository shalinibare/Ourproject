`include "alu_tb.sv"

module execute_tb();

logic[31:0] RegData0, RegData1, SPOut, imm, exeOut, RegData1_o;
logic ALU_A_SEL, MemInSel;
logic [4:0] opcode;
logic [1:0] ALU_B_SEL;

assign ALU_A_SEL = (opcode == 5'b01111) | (opcode == 5'b10000); //PUSH and POP
logic [1:0] B_SEL_TEMP;
always_comb begin
	if( (opcode == 5'b00001) | (opcode == 5'b00010) |
			(opcode[4:1] == 4'b0010) | (opcode == 5'b00110) |
			(opcode[4:1] == 4'b0110) | (opcode == 5'b01110)) begin //Imm
		B_SEL_TEMP = 2'b01;
	end else if ((opcode == 5'b10000) | (opcode == 5'b01111)) begin //4
		B_SEL_TEMP = 2'b10;
	end else begin //Reg1
		B_SEL_TEMP = 2'b00;
	end
end
assign ALU_B_SEL = B_SEL_TEMP;
assign MemInSel = (opcode == 5'b01111); //Memory address select PUSH

execute DUT(.*);

int errors;
alu_tc aluDriver;

initial begin
	RegData0 = 1;
	RegData1 = 2;
	SPOut = 4;
	imm = 3;
	opcode = 0;
	aluDriver = new();
	#5;
	for(int i = 0; i < 20; i++) begin //This will act as opcode loop
		opcode = i;
		
		#5;
		
	end
	
	if(errors > 0) begin
		$display("Test failed, errors found: $d", errors);
	end else begin
		$display("Test passed!");
	end
	$display("Simulation complete");
	$stop();
end

endmodule

