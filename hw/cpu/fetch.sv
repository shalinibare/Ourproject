/*
   CS/ECE 552 Spring '21
  
   Filename        : Fetch.v
   Description     : First State of the 5-Stage Processor
*/


// TODO: Branch prediction and funcitonality with LastPC which involved the pipelined verison of the CPU
module fetch #(parameter N=32) 
(
	
	output [N-1:0] inst,	// The line of instruction fetched from the instruction memory. 
											// It will be decoded to check if it is a branch instruction in 
											// order to perform branch prediction 

	output reg [N-1:0] PC,			// The incremented PC which will be stored in the IFDE pipeline 
											// register should the necessity of a branch not taken flush arise 

	input [N-1:0] LastPC,			// If branch weren’t taken, flush the branch PC and revert to the 
											// previous PC 
	input [N-1:0] BrPC,

	input rst_n, clk, Branch 			// Reset PC register on low 
);
	
	logic [31:0] nextPC;
	
	// PC Register
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			PC <= 32'h0;
		end else begin
			PC <= nextPC;
		end
	end
	
	
	// Instruction Memory
	memory2c instr_mem(.data_out(inst), .data_in(16'h0), .addr(PC), .enable(1'b1), .wr(1'b0), .createdump(1'b0), .clk(clk), .rst(~rst_n));

	// Sign Extension of Branch Offset (used in multistage)
	//assign BranchOffset = {15{{Instruction[16]}}, Instruction[16:0]};

	assign PCInc4 = PC + 4;

	// Mux right after the 2 adders
	assign nextPC = (Branch)?(BrPC):(PCInc4);

	// Mux right after the 2 adders (used in multistage)
	//assign adderMuxOutput = (Flush)?(LastPC):(pcBranch);
   
endmodule
