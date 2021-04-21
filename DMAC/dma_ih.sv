module DMA_IH
  #(parameter DATA_WIDTH=32, parameter ADDR_WIDTH=32, parameter int SIZE_WIDTH) 
(
    input clk, rst_n,
    input Rd_done,
    input Wr_done,
    input Ack,

    output [1:0] Intr

);
  reg [1:0] Intr; 
  
  always_ff @ (posedge clk or negedge rst_n) begin     
    if (~rst_n)
	      Intr <= 2'b00;
    else begin
      if (Ack)
        Intr <= 2'b00;
      elsif(Rd_done)
        Intr <= 2'b01;
      elsif(Wr_done)
        Intr <= 2'10;
     end
  end
endmodule
