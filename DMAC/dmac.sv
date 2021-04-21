
`include "cci_mpf_if.vh"

     
module DMAC
  #(parameter DATA_WIDTH=32, parameter ADDR_WIDTH=32, parameter int SIZE_WIDTH) 
(
    input clk, rst_n,
  
  	mmio_if.user HOST_MMIO_IF,
    dma_if.peripheral HOST_DMA_IF,
  
    input  Rd_go,
    input  [SIZE_WIDTH-1:0] Rd_size,
    input  [ADDR_WIDTH-1:0] Rd_addr,
    output [DATA_WIDTH-1:0] Rd_data,
    output Empty,
    input  Rd_en,
    output Rd_done,

    input Wr_go,
    input [SIZE_WIDTH-1:0] Wr_size,
    input Wr_size,
    input [ADDR_WIDTH-1:0] Wr_addr,
    input [DATA_WIDTH-1:0] Wr_data,
    output Full,
    input  Wr_en,
    output Wr_done

);



    always@(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            
        end
        if (CPUEn)
            CPUValid <= 1;
        else
            CPUValid <= 0; 
    end
    
endmodule
