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

    input [ADDR_WIDTH-1:0]CPUAddr,
          AclAddr,
          DMAAddr,

    input [DATA_WIDTH-1:0]CPUData,
          AclData,
          DMAData,

    output wire [DATA_WIDTH-1:0]CPUOut,
    AclOut,
    DMAOut,

    output reg CPUValid,
    AclValid,
    DMAValid
);

    logic [ADDR_WIDTH-1:0]AddrA;
    logic [ADDR_WIDTH-1:0]AddrB;

    logic [DATA_WIDTH-1:0]DataA;
    logic [DATA_WIDTH-1:0]DataB;

    logic signed [DATA_WIDTH-1:0]OutA;
    logic signed [DATA_WIDTH-1:0]OutB;

    logic WrA;
    logic WrB;

    reg BufferWr;
    reg [ADDR_WIDTH-1:0]BufferAddr;
    reg [DATA_WIDTH-1:0]BufferData;
    reg BufferFull;

    memory_map #(.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH))
    mem(.clk(clk), .rst_n(rst_n), .data_a(DataA), .data_b(DataB),
        .addr_a(AddrA), .addr_b(AddrB),
        .we_a(WrA), .we_b(WrB), .q_a(OutA), .q_b(OutB));

    
    assign DataA = CPUEn?CPUData:DMAData;
    assign DataB = AclEn?AclData:DMAData;
    assign AddrA = CPUEn?CPUAddr:DMAAddr;
    assign AddrB = AclEn?AclAddr:DMAAddr;
    assign WrA = CPUEn?CPUWrEn:DMAWrEn;
    assign WrB = AclEn?AclWrEn:DMAWrEn;
    assign CPUOut = OutA;
    assign AclOut = OutB;
    assign DMAOut = CPUValid?OutB:OutA;

    always@(posedge clk) begin
        if (CPUEn)
            CPUValid <= 1;
        else
            CPUValid <= 0;
    end
    
    // accessing sram
    /*
    always@(posedge clk, negedge rst_n) begin
        // fulfill CPU request
        if (CPUEn) begin
            // Prioritze CPU for port A
            AddrA <= CPUAddr;
            WrA <= CPUWrEn;
            DataA <= CPUData;
            if (CPUWrEn == 1) begin
                CPUValid <= 0;
            end else CPUValid <= 1'b1;
        end
        else begin
            CPUValid <= 1'b0;
            if (BufferFull&AclEn) begin
                // fulfill DMA queued request if port B is unavailable and port A is available
                AddrA <= BufferAddr;
                WrA <= BufferWr;
                DataA <= BufferData;
                BufferFull <=1'b0;
                if (DMAWrEn == 1) begin
                    DMAValid <= 0;
                end else DMAValid <= 1'b1;
            end
        end

        // fulfill Acl request
        if (AclEn) begin
            // Prioritze Acl for port B
            AddrB <= AclAddr;
            WrB <= AclWrEn;
            DataB <= AclData;
            if (AclWrEn == 1) begin
                AclValid <= 0;
            end else AclValid <= 1'b1;
        end
        else begin
            AclValid <= 1'b0;
            if (BufferFull) begin
                // fulfill DMA queued request if port B available
                AddrB <= BufferAddr;
                WrB <= BufferWr;
                DataB <= BufferData;
                BufferFull <=1'b0;
                if (DMAWrEn == 1) begin
                    DMAValid <= 0;
                end else DMAValid <= 1'b1;
            end
        end

        // fulfill DMA request if port B available or store this request to the buffer
        if (DMAEn) begin
            if(!AclEn) begin
                AddrB <= DMAAddr;
                WrB <= DMAWrEn;
                DataB <= DMAData;
                if (DMAWrEn == 1) begin
                    DMAValid <= 0;
                end else DMAValid <= 1'b1;
            end
            else if (!CPUEn) begin
                AddrA <= DMAAddr;
                WrA <= DMAWrEn;
                DataA <= DMAData;
                if (DMAWrEn == 1) begin
                    DMAValid <= 0;
                end else DMAValid <= 1'b1;
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
    end*/
    
endmodule