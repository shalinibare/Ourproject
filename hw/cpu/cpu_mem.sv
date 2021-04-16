/*
   CS/ECE 552 Spring '20
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/

// TODO: currently many unused signals, needs to be looked at once connected with other components

module memory #(parameter N=32)
( 

    // Input
	input           clk, rst_n, halt, memrd, memwr, valid,
    // Input and Output
	input   [N-1:0] Addr,      // Memory address to be accessed 
    //inout   [N-1:0] MemAddr0;   // Memory address being written/read to/from 
                                // MemInsel ? SPOut  :  ALUOut 
    input   [N-1:0] MemDataIn,  // Data that will be written into the memory
    output   [N-1:0] MemOut     // The read data from memory 

	// Output
    //output          MemEn0;     // Whether there is a request from the source module 
                                // (1 = Yes, 0 = No)
    //output          MemWrEn0;   // On write request, assert high. On read request, assert low 

);

	// Data Memory
	memory2c data_mem(
		.data_out(MemOut), .data_in(MemDataIn), .addr(Addr), .enable(memrd), 
		.wr(memwr), .createdump(halt), .clk(clk), .rst(rst_n));
   
endmodule
