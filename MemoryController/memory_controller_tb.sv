module memory_controller_tb ();
    localparam  DATA_WIDTH=32;
    localparam  ADDR_WIDTH=16;
    localparam  TEST_CASE=100;
    
    logic clk, rst_n;
    logic CPUEn, AclEn, DMAEn, CPUWrEn, AclWrEn,DMAWrEn;
    logic [ADDR_WIDTH-1:0]CPUAddr;
    logic [ADDR_WIDTH-1:0]AclAddr;
    logic [ADDR_WIDTH-1:0]DMAAddr;

    logic [DATA_WIDTH-1:0]CPUData;
    logic [DATA_WIDTH-1:0]AclData;
    logic [DATA_WIDTH-1:0]DMAData;

    logic [DATA_WIDTH-1:0]CPUOut;
    wire [DATA_WIDTH-1:0]AclOut;
    logic [DATA_WIDTH-1:0]DMAOut;

    reg CPUValid, AclValid, DMAValid;

    integer errors, mycycle;

    integer RandomVals [TEST_CASE];
    integer input_type [TEST_CASE];   
    always #5 begin 
        clk = ~clk;
        mycycle++;
    end

    memory_controller #(.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH))
    DUT(
    .clk(clk), 
    .rst_n(rst_n),
 
    .CPUEn(CPUEn),
    .AclEn(AclEn),
    .DMAEn(DMAEn),

    .CPUWrEn(CPUWrEn),
    .AclWrEn(AclWrEn),
    .DMAWrEn(DMAWrEn),

    .CPUAddr(CPUAddr),
    .AclAddr(AclAddr),
    .DMAAddr(DMAAddr),

    .CPUData(CPUData),
    .AclData(AclData),
    .DMAData(DMAData),

    .CPUOut(CPUOut),
    .AclOut(AclOut),
    .DMAOut(DMAOut),

    .CPUValid(CPUValid),
    .AclValid(AclValid),
    .DMAValid(DMAValid));

    initial begin
        mycycle= 0;
        clk = 1'b0;
        rst_n = 1'b0;
        errors = 0;
        CPUEn = 0;
        AclEn = 0;
        DMAEn = 0;
        CPUWrEn = 0;
        AclWrEn = 0;
        DMAWrEn = 0;
        CPUAddr = 0;
        AclAddr = 0;
        DMAAddr = 0;
        CPUData = 0;
        AclData = 0;
        DMAData = 0;
        @(negedge clk);
        rst_n = 1;
        // single port random write and read
        for ( int i = 0; i < TEST_CASE; i++) begin
            RandomVals[i] = $urandom();
            input_type [i] = $urandom();
            if(input_type[i]%3 == 0) begin
                CPUEn = 1;
                CPUWrEn = 1;
                CPUAddr = RandomVals[i];
                CPUData = RandomVals[i];
            end else begin
                CPUEn = 0;
                CPUWrEn = 0;
            end
            if(input_type[i]%3 == 1) begin
                AclEn = 1;
                AclWrEn = 1;
                AclAddr = RandomVals[i];
                AclData = RandomVals[i];
            end else begin
                AclEn = 0;
                AclWrEn = 0;
            end
            if(input_type[i]%3 == 2) begin
                DMAEn = 1;
                DMAWrEn = 1;
                DMAAddr = RandomVals[i];
                DMAData = RandomVals[i];
            end else begin
                DMAEn = 0;
                DMAWrEn = 0;
            end
            @(negedge clk);
        end
        $stop;
    end


endmodule