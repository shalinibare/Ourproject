// IMPORTANT!!!!!!!!!!!!!!!!!!!!!!!
// TB does not account for certain "IMPOSSIBLE" write and read sequences
// For example, write operation to addr lower than 1000 which is not one of the register will fail. addr = 002 for example.
// Since tb checks the values of output with an array of random input sored in RandomVals and RandomValsB
// if RNG writes to a close (+- 4) or the same addr, error will occur. In real operation, such write does not occur. Just ignore.

// directed tests for mmio reg.
// random for sram
// still need to test overwrite and read (overwrite test is passed at sram_tb)

module memory_map_tb ();
    localparam  DATA_WIDTH=32;
    localparam  ADDR_WIDTH=16;
    localparam  TEST_CASE=50;
    
    
    logic clk, rst_n;
    logic signed [DATA_WIDTH-1:0] data_a;
    logic signed [DATA_WIDTH-1:0] data_b;
    logic [(ADDR_WIDTH-1):0] addr_a; 
    logic [(ADDR_WIDTH-1):0] addr_b;
    logic we_a, we_b;
    logic signed [DATA_WIDTH-1:0] q_a;
    logic signed [DATA_WIDTH-1:0] q_b;

    logic signed [DATA_WIDTH-1:0] RandomVals [TEST_CASE];
    logic signed [DATA_WIDTH-1:0] RandomValsB [TEST_CASE];
    logic signed [DATA_WIDTH-1:0] mmio_reg [14];

    int addr;

    integer errors, mycycle;
    int cnt;

    always #5 begin 
        clk = ~clk;
        mycycle++;
    end


    memory_map #(.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH))
        DUT(.clk(clk), .rst_n(rst_n), .data_a(data_a), .data_b(data_b), .addr_a(addr_a), .addr_b(addr_b),
        .we_a(we_a), .we_b(we_b), .q_a(q_a), .q_b(q_b));

    initial begin
        mycycle= 0;
        clk = 1'b0;
        rst_n = 1'b0;
        errors = 0;
        we_a = 0;
        we_b = 0;
        @(negedge clk);
        rst_n = 1'b1;
        // test mmio register reset
        for(addr = 0; addr < 16'h f00; addr+= 16'h 100) begin
            if( addr != 16'h E00) begin
                addr_a = addr;
            end
            @(negedge clk);
            if (q_a != 0) begin
                errors++;
                $display("reg reset Error! Expected: %d, Got: %d at address %h. For loop: %h", 0 ,q_a, addr_a, cnt); 
            end
            else $display("reg reset trace! Expected: %d, Got: %d at address %h. For loop: %h", 0 ,q_a, addr_a, cnt); 
        end
        
        if (errors == 0) begin
            $display("Reset for mmio reg is a pass!");
        end
        @(negedge clk);
        cnt = 0;
        we_a = 1'b1;
        // test mmio register read write
        for(addr = 0; addr < 32'h f00; addr+= 32'h 100) begin
            if( addr != 32'h E00) begin
                addr_a = addr;
                mmio_reg[cnt] = $urandom();
                data_a = mmio_reg[cnt];
                cnt++;
            end
            @(negedge clk);
        end
        cnt = 0;
        we_a = 0;
        for(addr = 0; addr < 16'h e00; addr+= 16'h 100) begin
            if( addr != 16'h E00) begin
                addr_b = addr;
            end
            cnt++;
            @(negedge clk);
            if (q_b != mmio_reg[cnt-1]) begin
                errors++;
                 $display("reg read error! Expected: %d, Got: %d at address %h. At cycle: %d,cnt-1:%d", mmio_reg[cnt-1] ,q_b, addr, mycycle,cnt-1);  
            end 
            else $display("reg read trace! Expected: %d, Got: %d at address %h. At cycle: %d,cnt-1:%d", mmio_reg[cnt-1] ,q_b, addr, mycycle,cnt-1);  
             
        end
        if (errors == 0) begin
            $display("mmio read write reg is a pass!");
        end
        
        // random memeory write and read
        @(negedge clk);
        we_a = 1;
        we_b = 1;
        for(int i = 0; i < TEST_CASE; ++i) begin
             //@(negedge clk);
             RandomVals[i] = $urandom();
             RandomValsB[i] = $urandom();
             addr_a = RandomVals[i];
             data_a = RandomVals[i];
             addr_b = RandomValsB[i];
             data_b = RandomValsB[i];
             @(negedge clk);
        end
        
        
        @(negedge clk);
        we_a = 0;
        we_b = 0;

        for(int i = 0; i < TEST_CASE; i++) begin
            addr_a = RandomVals[i];
            addr_b = RandomValsB[i];
            @(negedge clk);
            if (q_a != RandomVals[i]) begin
                errors++;
                 $display("sram read  port A error! Expected: %d, Got: %d at address %h. At cycle: %d.", RandomVals[i] ,q_a, addr_a, mycycle);  
            end 
            else $display("sram read port A trace! Expected: %d, Got: %d at address %h. At cycle: %d.", RandomVals[i] ,q_a, addr_a, mycycle);  

            
            
            if (q_b != RandomValsB[i]) begin
                errors++;
                 $display("sram read port B error! Expected: %d, Got: %d at address %h. At cycle: %d.", RandomValsB[i] ,q_b, addr_b, mycycle);  
            end 
            
            else $display("sram read port B trace! Expected: %d, Got: %d at address %h. At cycle: %d.", RandomValsB[i] ,q_b, addr_b, mycycle);  
            
            
        end

        @(negedge clk);


        if (errors == 0) begin
            $display("sram read is a pass!");
        end
        

        $stop;



    end

endmodule