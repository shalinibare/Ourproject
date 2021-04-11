/*
   CS/ECE 552 Spring '20
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
module memory (clk, rst, aluResult, writeData, memWrite, memRead, data_out, halt);
	parameter N= 16;
	input clk, rst;
	input [N-1:0] aluResult;
	input [15:0] writeData;	// data to be written into the data mem
	input memWrite;			// Control Signal for if to write into the memory
	input memRead;			// Control Signal for if to read from data mem
	output [15:0] data_out;		// data output from data mem
	input halt;		// Control Signal for when Halt happens 

	// Data Memory Instatiation
	memory2c data_mem(
		.data_out(data_out), .data_in(writeData), .addr(aluResult), .enable(memRead), 
		.wr(memWrite), .createdump(halt), .clk(clk), .rst(rst));
   
endmodule
