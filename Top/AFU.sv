// Copyright (c) 2020 University of Florida
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// Greg Stitt
// University of Florida

// Module Name:  afu.sv
// Project:      dma_loopback
// Description:  This AFU provides a loopback DMA test that simply reads
//               data from one array in the CPU's memory and writes the
//               received data to a separate array. The AFU uses MMIO to
//               receive the starting read adress, starting write address,
//               size (# of cache lines to read/wite), and a go signal. The
//               AFU asserts a done signal to tell software that the DMA
//               transfer is complete.
//
//               One key difference with this AFU is that it does not use
//               CCI-P, which is abstracted away by a hardware abstraction
//               layer (HAL). Instead, the AFU uses a simplified MMIO interface
//               and DMA interface.
//
//               The MMIO interface is defined in mmio_if.vh. It behaves
//               similarly to the CCI-P functionality, except only supports
//               single-cycle MMIO read responses, which eliminates the need
//               for transaction IDs. MMIO writes behave identically to
//               CCI-P.
//
//               The DMA read interface takes a starting read address (rd_addr),
//               and a read size (rd_size) (# of cache lines to read). The rd_go
//               signal starts the transfer. When data is available from memory
//               the empty signal is cleared (0 == data available) and the data
//               is shown on the rd_data port. To read the data, the AFU should
//               assert the read enable (rd_en) (active high) for one cycle.
//               The rd_done signal is continuously asserted (active high) after
//               the AFU reads "size" words from the DMA.
//
//               The DMA write interface is similar, again using a starting
//               write address (wr_addr), write size (wr_size), and go signal.
//               Before writing data, the AFU must ensure that the write
//               interface is not full (full == 0). To write data, the AFU
//               puts the corresponding data on wr_data and asserts wr_en
//               (active high) for one cycle. The wr_done signal is continuosly
//               asserted after size cache lines have been written to memory.
//
//               All addresses are virtual addresses provided by the software.
//               All data elements are cachelines.
//

//===================================================================
// Interface Description
// clk  : Clock input
// rst  : Reset input (active high)
// mmio : Memory-mapped I/O interface. See mmio_if.vh and description above.
// dma  : DMA interface. See dma_if.vh and description above.
//===================================================================

`include "cci_mpf_if.vh"

module afu 
  (
   input clk,
   input rst,
	 mmio_if.user mmio_if,
	 dma_if.peripheral dma_if
   );

   localparam int CL_ADDR_WIDTH = $size(t_ccip_clAddr);
      
   // I want to just use dma.count_t, but apparently
   // either SV or Modelsim doesn't support that. Similarly, I can't
   // just do dma.SIZE_WIDTH without getting errors or warnings about
   // "constant expression cannot contain a hierarchical identifier" in
   // some tools. Declaring a function within the interface works just fine in
   // some tools, but in Quartus I get an error about too many ports in the
   // module instantiation.
   typedef logic [CL_ADDR_WIDTH:0] count_t;   
   count_t 	size;
   logic 	go;
   logic 	done;

   // Software provides 64-bit virtual byte addresses.
   // Again, this constant would ideally get read from the DMA interface if
   // there was widespread tool support.
   localparam int VIRTUAL_BYTE_ADDR_WIDTH = 64;

   // Instantiate the memory map, which provides the starting read/write
   // 64-bit virtual byte addresses, a transfer size (in cache lines), and a
   // go signal. It also sends a done signal back to software.
   memory_map
     #(
       .ADDR_WIDTH(VIRTUAL_BYTE_ADDR_WIDTH),
       .SIZE_WIDTH(CL_ADDR_WIDTH+1)
       )
   memory_map (.*);

   wire local_dma_re, local_dma_we;

   wire [1:0] mem_op;
   wire [VIRTUAL_BYTE_ADDR_WIDTH-1:0] cpu_addr;
   logic [VIRTUAL_BYTE_ADDR_WIDTH-1:0] wr_addr;
   wire tx_done;
   wire ready;
   wire rd_valid;
   wire rd_go;
   wire wr_go;

   wire [31:0] cpu_in;
   wire [31:0] cpu_out; // Todo, parameterize
     
    // DMA Signals. Parameters to be globally taken care of later
    localparam int ADDR_WIDTH = 64;
    localparam int DATA_WIDTH = 32;
    localparam int SIZE_WIDTH = 16;

    wire dma_rd_go,
    wire [SIZE_WIDTH-1:0] dma_rd_size,
    wire [ADDR_WIDTH-1:0] dma_rd_addr,
    wire [DATA_WIDTH-1:0] dma_d_data,
    wire dma_empty,
    wire dma_rd_en,
    wire dma_rd_done,

    wire dma_wr_go,
    wire [SIZE_WIDTH-1:0] dma_wr_size,
    wire [ADDR_WIDTH-1:0] dma_wr_addr,
    wire [DATA_WIDTH-1:0] dma_wr_data,
    wire dma_full,
    wire dma_wr_en,
    wire dma_wr_done
  
   //to be replaced by the real one..
   cpu
   mock
   (
       .clk(clk),
       .rst_n(~rst),
       .tx_done(tx_done),
       .rd_valid(rd_valid),
       .op(mem_op),
       .io_address(cpu_addr),
       .common_data_bus_in(cpu_in),
       .common_data_bus_out(cpu_out)
   );

   // Memory Controller module - to be replaced by the new one
   mem_ctrl
   memory(
       .clk(clk),
       .rst_n(~rst),
       .host_init(go),
       .host_rd_ready(~dma.empty),
       .host_wr_ready(~dma.full),
       .op(mem_op), // CPU Defined
       .raw_address(cpu_addr), // Address in the CPU space
       .address_offset(wr_addr),
       .common_data_bus_read_in(cpu_out), // CPU data word bus, input
       .common_data_bus_write_out(cpu_in),
       .host_data_bus_read_in(dma.rd_data),
       .host_data_bus_write_out(dma.wr_data),
       .corrected_address(final_addr),
       .ready(ready), // Usable for the host CPU
       .tx_done(tx_done), // Again, notifies CPU when ever a read or write is complete
       .rd_valid(rd_valid), // Notifies CPU whenever the data on the databus is valid
       .host_re(local_dma_re),
       .host_we(local_dma_we),
       .host_rgo(rd_go),
       .host_wgo(wr_go)
   );

  DMAC DMA_CTLR(
      .clk( clk ),
      .rst_n( ~rst ),  
    
      .HOST_DMA_IF( dma_if ),
      .Base_addr( wr_addr ), //Set by the MMIO write in Memory map module
     
      .Rd_go( dma_rd_go ),
      .Rd_size( dma_rd_size ),
      .Rd_addr( dma_rd_addr ),
      .Rd_data( dma_rd_data ),
      .Empty( dma_empty ),
      .Rd_en( dma_rd_en ),
      .Rd_done( dma_rd_done ),

      .Wr_go( dma_wr_go ),
      .Wr_size( dma_wr_size ),
      .Wr_addr( dma_wr_addr ),
      .Wr_data( dma_wr_data ),
      .Full( dma_full ),
      .Wr_en( dma_wr_en ),
      .Wr_done( dma_wr_done )
  );
    
            
endmodule
