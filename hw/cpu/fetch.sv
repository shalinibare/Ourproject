/*
   CS/ECE 552 Spring '20
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/

module fetch(instr, addr_out, /* jump_ctrl ,*/ addr_in, rst, clk);

	parameter N = 16;

	output[N-1:0] 	instr;
	output [N-1:0] 	addr_out;
	// input		jump_ctrl;
	input [N-1:0]   addr_in;
	input 		rst;
	input 		clk;


	// WIRES
	// wire [N-1:0] pcAddr;
	wire [N-1:0] pcCurrent;

	// MUX right before the PC counter

	// mux_2_1_16b whichPCMux(.InA(addr0), .InB(addr1), .S(jump_ctrl), .Out(pcAddr));
	
	// Register that holds the Program Counter
	
	reg_16b pcReg(.q_16(pcCurrent),
                .clk(clk), .rst(rst), .d_16(addr_in), .writeEn(1'b1));
	//might need to change writeEn to include halt createdump

	// Instruction Memory
	
	memory2c instr_mem(.data_out(instr), .data_in(16'h0), .addr(pcCurrent), .enable(1'b1), .wr(1'b0), .createdump(1'b0), .clk(clk), .rst(rst));

	// Adder for PC
	cla_16b adder(.A(pcCurrent), .B(16'h4), .C_in(1'b0), .S(addr_out), .C_out());
   
endmodule
