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
    integer RandomValsB [TEST_CASE];
    integer input_type [TEST_CASE];   
    integer input_typeB [TEST_CASE];
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
            input_type [i] = $urandom()%3;
            if(input_type[i]== 0) begin
                CPUEn = 1;
                CPUWrEn = 1;
                CPUAddr = RandomVals[i];
                CPUData = RandomVals[i];
            end else begin
                CPUEn = 0;
                CPUWrEn = 0;
            end
            if(input_type[i]== 1) begin
                AclEn = 1;
                AclWrEn = 1;
                AclAddr = RandomVals[i];
                AclData = RandomVals[i];
            end else begin
                AclEn = 0;
                AclWrEn = 0;
            end
            if(input_type[i]== 2) begin
                DMAEn = 1;
                DMAWrEn = 1;
                DMAAddr = RandomVals[i];
                DMAData = RandomVals[i];
            end else begin
                DMAEn = 0;
                DMAWrEn = 0;
            end
            @(negedge clk);

            if(input_type[i]== 0) begin
                $display("single read trace: CPU expected:%h, got:%h, CPUValid:%d, AclValid:%d DMAValid:%d .at cycle:%d",RandomVals[i],CPUOut, CPUValid, AclValid, DMAValid,mycycle); 
                if(CPUOut != RandomVals[i]) begin
                   errors++;
                   $display("single read error: CPU expected:%h, got:%h, at cycle:%d",RandomVals[i],CPUOut,mycycle); 
                end
                if(CPUValid != 1) begin
                    $display("CPUValid error: expected: 1, got:%d",CPUValid);
                end
                if(DMAValid == 1) begin
                    $display("DMAValid:%d, error! this is a cpu read", DMAValid);
                end
                if(AclValid == 1) begin
                    $display("AclValid:%d, error! this is a cpu read", AclValid);
                end
            end

            if(input_type[i]== 1) begin
                $display("single read trace: Acl expected:%h, got:%h, AclValid:%d, CPUValid:%d, DMAValid:%d .at cycle:%d",RandomVals[i],AclOut, AclValid, CPUValid, DMAValid,mycycle); 
                if(AclOut != RandomVals[i]) begin
                   errors++;
                   $display("single read error: Acl expected:%h, got:%h, at cycle:%d",RandomVals[i],AclOut,mycycle); 
                end
                if(AclValid != 1) begin
                    $display("CPUValid error: expected: 1, got:%d",AclValid);
                end
                if(DMAValid == 1) begin
                    $display("DMAValid:%d, error! this is a cpu read", DMAValid);
                end
                if(CPUValid == 1) begin
                    $display("CPUValid:%d, error! this is a cpu read", CPUValid);
                end
            end
            if(input_type[i]== 2) begin
                $display("single read trace: DMA expected:%h, got:%h, DMAValid:%d, CPUValid:%d, AclValid:%d .at cycle:%d",RandomVals[i],DMAOut, DMAValid, CPUValid,AclValid,mycycle); 
                if(DMAOut != RandomVals[i]) begin
                   errors++;
                   $display("single read error: DMA expected:%h, got:%h, at cycle:%d",RandomVals[i],DMAOut,mycycle); 
                end
                if(DMAValid != 1) begin
                    $display("CPUValid error: expected: 1, got:%d",DMAValid);
                end
                if(CPUValid == 1) begin
                    $display("DMAValid:%d, error! this is a cpu read", CPUValid);
                end
                if(AclValid == 1) begin
                    $display("AclValid:%d, error! this is a cpu read", AclValid);
                end
            end
        end

        if (errors == 0) begin
            $display("Single port read/write is a pass!");
        end

        @(negedge clk);
        //dual port write/read
        for ( int i = 0; i < TEST_CASE; i++) begin
            RandomVals[i] = $urandom();
            RandomValsB[i] = $urandom();
            //input_type [i] = $urandom()%3;
            input_typeB [i] = (input_type[i] + $urandom()%2+1)%3;
            CPUEn = 0;
            CPUWrEn = 0;
            AclEn = 0;
            AclWrEn = 0;
            DMAEn = 0;
            DMAWrEn = 0;
            if(input_type[i]== 0) begin
                CPUEn = 1;
                CPUWrEn = 1;
                CPUAddr = RandomVals[i];
                CPUData = RandomVals[i];
            end
            if(input_type[i]== 1) begin
                AclEn = 1;
                AclWrEn = 1;
                AclAddr = RandomVals[i];
                AclData = RandomVals[i];
            end
            if(input_type[i]== 2) begin
                DMAEn = 1;
                DMAWrEn = 1;
                DMAAddr = RandomVals[i];
                DMAData = RandomVals[i];
            end

            if(input_typeB[i]== 0) begin
                CPUEn = 1;
                CPUWrEn = 1;
                CPUAddr = RandomValsB[i];
                CPUData = RandomValsB[i];
            end
            if(input_typeB[i]== 1) begin
                AclEn = 1;
                AclWrEn = 1;
                AclAddr = RandomValsB[i];
                AclData = RandomValsB[i];
            end
            if(input_typeB[i]== 2) begin
                DMAEn = 1;
                DMAWrEn = 1;
                DMAAddr = RandomValsB[i];
                DMAData = RandomValsB[i];
            end

            @(negedge clk);

            if(input_type[i]== 0) begin
                $display("single read trace: CPU expected:%h, got:%h, CPUValid:%d, AclValid:%d DMAValid:%d .at cycle:%d",RandomVals[i],CPUOut, CPUValid, AclValid, DMAValid,mycycle); 
                if(CPUOut != RandomVals[i]) begin
                   errors++;
                   $display("single read error: CPU expected:%h, got:%h, at cycle:%d",RandomVals[i],CPUOut,mycycle); 
                end

            end
            if(input_type[i]== 1) begin
                $display("single read trace: Acl expected:%h, got:%h, AclValid:%d, CPUValid:%d, DMAValid:%d .at cycle:%d",RandomVals[i],AclOut, AclValid, CPUValid, DMAValid,mycycle); 
                if(AclOut != RandomVals[i]) begin
                   errors++;
                   $display("single read error: Acl expected:%h, got:%h, at cycle:%d",RandomVals[i],AclOut,mycycle); 
                end

            end
            if(input_type[i]== 2) begin
                $display("single read trace: DMA expected:%h, got:%h, DMAValid:%d, CPUValid:%d, AclValid:%d .at cycle:%d",RandomVals[i],DMAOut, DMAValid, CPUValid,AclValid,mycycle); 
                if(DMAOut != RandomVals[i]) begin
                   errors++;
                   $display("single read error: DMA expected:%h, got:%h, at cycle:%d",RandomVals[i],DMAOut,mycycle); 
                end

            end

            if(input_typeB[i] == 0) begin
                $display("single read trace: CPU expected:%h, got:%h, CPUValid:%d, AclValid:%d DMAValid:%d .at cycle:%d",RandomValsB[i],CPUOut, CPUValid, AclValid, DMAValid,mycycle); 
                if(CPUOut != RandomValsB[i]) begin
                   errors++;
                   $display("single read error: CPU expected:%h, got:%h, at cycle:%d",RandomValsB[i],CPUOut,mycycle); 
                end

            end

            if(input_typeB[i]== 1) begin
                $display("single read trace: Acl expected:%h, got:%h, AclValid:%d, CPUValid:%d, DMAValid:%d .at cycle:%d",RandomValsB[i],AclOut, AclValid, CPUValid, DMAValid,mycycle); 
                if(AclOut != RandomValsB[i]) begin
                   errors++;
                   $display("single read error: Acl expected:%h, got:%h, at cycle:%d",RandomValsB[i],AclOut,mycycle); 
                end

            end
            if(input_typeB[i]== 2) begin
                $display("single read trace: DMA expected:%h, got:%h, DMAValid:%d, CPUValid:%d, AclValid:%d .at cycle:%d",RandomValsB[i],DMAOut, DMAValid, CPUValid,AclValid,mycycle); 
                if(DMAOut != RandomValsB[i]) begin
                   errors++;
                   $display("single read error: DMA expected:%h, got:%h, at cycle:%d",RandomVals[i],DMAOut,mycycle); 
                end

            end
        end

        if (errors == 0) begin
            $display("dual port read/write is a pass!");
        end

        @(negedge clk);
        // directed test
        CPUEn = 1;
        CPUWrEn = 1;
        AclEn = 1;
        AclWrEn = 1;
        DMAEn = 1;
        DMAWrEn = 1;
        CPUAddr = 32'h 2000;
        DMAAddr = 32'h 3000;
        AclAddr = 32'h 4000;
        CPUData = 1;
        AclData = 2;
        DMAData = 3;
        @(negedge clk);
        CPUEn = 0;
        CPUWrEn = 0;
        AclEn = 0;
        AclWrEn = 0;
        DMAEn = 0;
        DMAWrEn = 0;
        if(CPUValid != 1 & AclValid != 1 | DMAValid == 1) begin
            errors++;
        end
        $display("Three concurrent write trace: CPU expected:1, got:%h. Acl expected:2, got:%h. DMA Expected:3, got:%h. CPUV:%d, AclV:%d,DMA:%d.", CPUOut,AclOut,DMAOut,CPUValid,AclValid,DMAValid);
        @(negedge clk);
        $display("Buffer write: DMA Expected:3, got:%h. DMAV:%d.", DMAOut,DMAValid);
        $stop;
    end


endmodule