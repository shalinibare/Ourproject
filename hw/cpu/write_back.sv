/*
   CS/ECE 552 Spring '20
  
   Filename        : wb.v
   Description     : This is the module for the overall Write Back stage of the processor.
*/
module wb (memToReg, readData, addr, data_output);
	input memToReg;			// control signal if something from mem is going to a reg
	input [15:0] readData;		// data coming out of the data mem
	input [15:0] addr;		// data coming into the data mem as the address
	output [15:0] data_output;  	// output of the write back

	wire [15:0] data_mem_mux;
	
	// Mux Right After the Data Mem
	assign data_output = (memToReg)?(readData):(addr);

	// Second Mux for choosing data that same from somewhere else 
   
endmodule
