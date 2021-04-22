
     
module DMAC
  #(parameter DATA_WIDTH=32, parameter ADDR_WIDTH=32, parameter int SIZE_WIDTH) 
(
    input clk, rst_n,
  
    //mmio_if.user HOST_MMIO_IF, 
    dma_if.peripheral HOST_DMA_IF,
    input  [ADDR_WIDTH-1:0] Base_addr, //Set by the Host through MMIO? To be taken care in AFU
     
    input  Rd_go,
    input  [SIZE_WIDTH-1:0] Rd_size,
    input  [ADDR_WIDTH-1:0] Rd_addr,
    output [DATA_WIDTH-1:0] Rd_data,
    output Empty,
    input  Rd_en,
    output Rd_done,

    input Wr_go,
    input [SIZE_WIDTH-1:0] Wr_size,
    input [ADDR_WIDTH-1:0] Wr_addr,
    input [DATA_WIDTH-1:0] Wr_data,
    output Full,
    input  Wr_en,
    output Wr_done

);

   assign HOST_DMA_IF.rd_addr = Base_addr + Rd_addr;
   assign HOST_DMA_IF.wr_addr = Base_addr + Wr_addr;
   
   assign HOST_DMA_IF.wr_data = Wr_data;
   assign Rd_data = HOST_DMA_IF.rd_data;
     
   assign HOST_DMA_IF.rd_size = Rd_size;
   assign HOST_DMA_IF.wr_size = Wr_size;

   assign HOST_DMA_IF.rd_go = Rd_go;
   assign HOST_DMA_IF.wr_go = Wr_go;
     
   assign Empty = HOST_DMA_IF.empty;
   assign Full = HOST_DMA_IF.full;
     
   assign HOST_DMA_IF.rd_en = Rd_en;
   assign HOST_DMA_IF.wr_en = Wr_en;
     
   assign Wr_done = HOST_DMA_IF.wr_done;
   assign Rr_done = HOST_DMA_IF.rd_done;

endmodule
