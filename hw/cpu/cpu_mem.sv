/*
   CS/ECE 552 Spring '20
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/

// TODO: currently many unused signals, needs to be looked at once connected with other components

module memory ( /* Input */     clk, rst_n, memrd, halt, Valid,
                /* Inout */     Addr, MemWr, MemAddr0, MemDataIn, MemOut,
                /* Output */    MemEn0, MemWrEn0);

	parameter N= 32;

    // Input
	input           clk; 
    input           rst_n ;     // Reset PC register on low 
    input           halt;       // for memory2c
	input           memrd;		// Memory read enable 
    input           Valid;		// After requesting the memory, stall the pipeline 
                                // until Valid is set high

    // Input and Output
	inout   [N-1:0] Addr;       // Memory address to be accessed 
    inout           MemWr;		// Memory write enable 
    inout   [N-1:0] MemAddr0;   // Memory address being written/read to/from 
                                // MemInsel ? SPOut  :  ALUOut 
    inout   [N-1:0] MemDataIn;  // Data that will be written into the memory
    inout   [N-1:0] MemOut;     // The read data from memory 

	// Output
    output          MemEn0;     // Whether there is a request from the source module 
                                // (1 = Yes, 0 = No)
    output          MemWrEn0;   // On write request, assert high. On read request, assert low 

	

	// Data Memory
	memory2c data_mem(
		.MemOut(MemOut), .data_in(MemDataIn), .addr(Addr), .enable(memrd), 
		.wr(MemWr), .createdump(halt), .clk(clk), .rst(rst_n));
   
endmodule
