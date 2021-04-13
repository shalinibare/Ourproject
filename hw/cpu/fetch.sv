/*
   CS/ECE 552 Spring '21
  
   Filename        : Fetch.v
   Description     : First State of the 5-Stage Processor
*/

module fetch(Instruction, addr_out, LastPC, PCInc4, addr_in, rst, clk);

	parameter N = 32;

	output		[N-1:0] 	Instruction;
	output reg 	[N-1:0] 	addr_out;
	output		[N-1:0]		PCInc4;

	input 		[N-1:0]		LastPC;
	input 		[N-1:0]		addr_in;
	input					rst;
	input 					clk;
	
	wire 		[N-1:0] 	pcCurrent;
	wire 					Flush;
	wire					BranchTaken;
	wire		[N-1:0] 	BranchOffset;

	
	// Register that holds the Program Counter
	reg_Nb #(N = 32) pcReg(.q_N(pcCurrent),
                .clk(clk), .rst(rst), .d_N(addr_in), .writeEn(1'b1));

	// Instruction Memory
	memory2c instr_mem(.data_out(Instruction), .data_in(16'h0), .addr(pcCurrent), .enable(1'b1), .wr(1'b0), .createdump(1'b0), .clk(clk), .rst(rst));


	always @(posedge clk) begin
		addr_out = pcCurrent + 32'h4
	end
   
endmodule
