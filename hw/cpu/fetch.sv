/*
   CS/ECE 552 Spring '21
  
   Filename        : Fetch.v
   Description     : First State of the 5-Stage Processor
*/


// TODO: Branch prediction and funcitonality with LastPC which involved the pipelined verison of the CPU
module fetch(Instruction, PCInc4, LastPC, rst_n, clk, BranchTaken);

	parameter N = 32;
	
	output		[N-1:0] 	Instruction;	// The line of instruction fetched from the instruction memory. 
											// It will be decoded to check if it is a branch instruction in 
											// order to perform branch prediction 

	output		[N-1:0]		PCInc4;			// The incremented PC which will be stored in the IFDE pipeline 
											// register should the necessity of a branch not taken flush arise 

	input 		[N-1:0]		LastPC;			// If branch weren’t taken, flush the branch PC and revert to the 
											// previous PC 

	input					rst_n; 			// Reset PC register on low 
	input 					clk;
	input 					BranchTaken;	// Comes from Decode stage
	
	wire 		[N-1:0] 	thisPC;
	wire 		[N-1:0] 	nextPC;
	wire 					Flush;
	reg			[N-1:0] 	BranchOffset;
	wire		[N-1:0] 	pcBranch;
	wire		[N-1:0] 	adderMuxOutput;
	

	
	// PC Register
	reg_Nb #(N = 32) pcReg(.q_N(thisPC),
                .clk(clk), .rst_n(rst_n), .d_N(nextPC), .writeEn(1'b1));

	// Instruction Memory
	memory2c instr_mem(.data_out(Instruction), .data_in(16'h0), .addr(thisPC), .enable(1'b1), .wr(1'b0), .createdump(1'b0), .clk(clk), .rst(rst));

	// Sign Extension of Branch Offset
	assign BranchOffset = {15{{Instruction[16]}}, Instruction[16:0]};

	// 2 Adders
	always @(posedge clk) begin
		// currentPC + 4
		PCInc4 <= thisPC + 32'h4
		// BranchOffset + thisPC
		pcBranch <= thisPC + BranchOffset
	end

	// Mux right after the 2 adders
	assign adderMuxOutput = (BranchTaken)?(pcBranch):(PCInc4);

	// Mux right after the 2 adders
	assign adderMuxOutput = (Flush)?(LastPC):(pcBranch);
   
endmodule
