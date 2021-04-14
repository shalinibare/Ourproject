/*
   CS/ECE 554 Spring '21
  
   Filename        : write_back.v
   Description     : This is the module for the overall Write Back stage of the processor.
*/
module write_back (memToReg, readData, addr, data_output);
	input memToReg;			// control signal if something from mem is going to a reg
	input [31:0] readData;		// data coming out of the data mem
	input [31:0] addr;		// data coming into the data mem as the address
	output [31:0] data_output;  	// output of the write back
	output [31:0] data_output;  	// output of the write

	// wire [15:0] data_mem_mux;
	
	// Mux Right After the Data Mem
	assign data_output = (memToReg)?(readData):(addr);
	assign data_output = (memToReg)?(readData):(addr);

	// Second Mux for choosing data that same from somewhere else 
   
endmodule
