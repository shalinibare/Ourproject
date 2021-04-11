// Priority memory access: CPU > Acl > DMA

module memory_controller
#(parameter DATA_WIDTH=32, parameter ADDR_WIDTH=32) 
(
    input clk, rst_n,
    
    CPUEn,
    AclEn,
    DMAEn,

    CPUWrEn,
    AclWrEn,
    DMAWrEn,

    input CPUAddr[ADDR_WIDTH-1:0],
    AclAddr[ADDR_WIDTH-1:0],
    DMAAddr[ADDR_WIDTH-1:0],

    input CPUData[DATA_WIDTH-1:0],
    AclData[DATA_WIDTH-1:0],
    DMAData[DATA_WIDTH-1:0],

    output logic CPUOut[DATA_WIDTH-1:0],
    logic AclOut[DATA_WIDTH-1:0],
    logic DMAOut[DATA_WIDTH-1:0],

    output reg CPUValid,
    reg AclValid,
    reg DMAValid
);

    logic AddrA[ADDR_WIDTH-1:0];
    logic AddrB[ADDR_WIDTH-1:0];

    logic DataA[DATA_WIDTH-1:0];
    logic DataB[DATA_WIDTH-1:0];

    logic OutA[DATA_WIDTH-1:0];
    logic OutB[DATA_WIDTH-1:0];

    logic WrA;
    logic WrB;

    reg BufferWr;
    reg BufferAddr[ADDR_WIDTH-1:0];
    reg BufferData[DATA_WIDTH-1:0];
    reg BufferFull;

    memory_map #(.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH))
    mem(.data_a(DataA),.data_b(DataB),.addr_a(AddrA),.addr_b(Addr_B),.we_a(WrA),.we_b(WrB),.clk(clk),.q_a(OutA),.q_b(OutB));


    // accessing sram
    always@(posedge clk, negedge rst_n) begin
        // fulfill CPU request
        if (CPUEn) begin
            // Prioritze CPU for port A
            AddrA <= CPUAddr;
            WrA <= CPUWrEn;
            DataA <= CPUData;
            CPUValid <= 1'b1;
            CPUOut <= OutA;
        end
        else begin
            CPUValid <= 1'b0;
            if (BufferFull) begin
                // fulfill DMA request if port A available
                AddrA <= BufferAddr;
                WrA <= BufferWr;
                DataA <= BufferData;
                DMAValid <= 1'b1;
                DMAOut <= OutA;
                BufferFull <=1'b0;
            end
        end

        // fulfill Acl request
        if (AclEn) begin
            // Prioritze Acl for port B
            AddrB <= AclAddr;
            WrB <= AclWrEn;
            DataB <= AclData;
            AclOut <= OutB;
            AclValid <= 1'b1;
        end
        else begin
            AclValid <= 1'b0;
            if (BufferFull) begin
                // fulfill DMA request if port B available
                AddrB <= BufferAddr;
                WrB <= BufferWr;
                DataB <= BufferData;
                DMAValid <= 1'b1;
                DMAOut <= OutB;
                BufferFull <=1'b0;
            end
        end

        // fulfill DMA request if port B available or store this request to the buffer
        if (DMAEn) begin
            if(!AclEn) begin
                AddrB <= DMAAddr;
                WrB <= DMAWrEn;
                DataB <= DMAData;
                DMAOut <= OutB;
                DMAValid <= 1'b1;
            end
            else begin
                BufferAddr <= DMAAddr;
                BufferWr <= DMAWrEn;
                BufferData <= DMAData;
                BufferFull <= 1'b1;
            end
        end
        else begin
            DMAValid <= 1'b0;
        end
    end
    
endmodule