/*
   CS/ECE 554, Spring '21
   
  
   This module creates a register of a specified dimension
   with the paramenter N
*/



module reg_Nb 
               #(
               parameter N = 32;
               )
               (
                // Outputs
                q_N,
                // Inputs
                clk, rst_n, d_N, writeEn
                );

   input                clk, rst_n;
   input                writeEn;
   input          [N-1:0]  d_N;
   output   reg   [N-1:0]  q_N;

   always @(posedge clk) begin
      if (!rst_n)
         q_N = 0;
      else 
         q_N = d_N;
   end


endmodule
