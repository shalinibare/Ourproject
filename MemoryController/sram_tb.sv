module sram_tb ();
    localparam  DATA_WIDTH=32;
    localparam  ADDR_WIDTH=3;

    logic clk;
    logic signed [DATA_WIDTH-1:0] data_a;
    logic signed [DATA_WIDTH-1:0] data_b;
    logic [(ADDR_WIDTH-1):0] addr_a; 
    logic [(ADDR_WIDTH-1):0]addr_b;
    logic we_a, we_b;
    logic signed [DATA_WIDTH-1:0]q_a;
    logic signed [DATA_WIDTH-1:0] q_b;

    logic signed [DATA_WIDTH-1:0] RandomVals [2**ADDR_WIDTH-1:0];
    logic signed [DATA_WIDTH-1:0] RandomValsB [2**ADDR_WIDTH-1:0];

    always #5 clk = ~clk;

    integer errors, mycycle;

    sram #(.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH))
        DUT(.*);

    initial begin
        clk = 1'b0;
        errors = 0;
        we_a = 0;
        we_b = 0;
//  ONE PORT
        @(posedge clk);
        //1 port write
        
        for(int addr = 0; addr < 2**ADDR_WIDTH; addr++)begin
            @(posedge clk);
            we_a = 1;
            RandomVals[addr] = $urandom();
            addr_a = addr;
            data_a = RandomVals[addr];
        end
        @(posedge clk);
        we_a = 0;
        addr_a = 0;
        @(posedge clk);
        // 1 port read
        for(int addr = 1; addr < 2**ADDR_WIDTH+1; addr++)begin
            addr_a = addr;
            @(posedge clk);
            if(RandomVals[addr-1] != q_a) begin
                errors++;
                $display("Error! Expected: %d, Got: %d at address %h. For loop: %d", RandomVals[addr-1] ,q_a, addr_a, addr); 
            end
        end

        // repeated read
        for(int addr = 1; addr < 2**ADDR_WIDTH+1; addr++)begin
            addr_a = addr;
            @(posedge clk);
            if(RandomVals[addr-1] != q_a) begin
                errors++;
                $display("Error! Expected: %d, Got: %d at address %h. For loop: %d", RandomVals[addr-1] ,q_a, addr_a, addr); 
            end
        end
        if (errors == 0) begin
            $display("Write and read for single port is a pass!");
        end


//  DUAL PORT

        @(posedge clk);
        errors = 0;
        // 2 port write
        for(int addr = 0; addr < 2**ADDR_WIDTH/2; addr++)begin
            @(posedge clk);
            we_a = 1;
            we_b = 1;
            RandomVals[addr] = $urandom();
            addr_a = addr;
            data_a = RandomVals[addr];

            RandomValsB[addr] = $urandom();
            addr_b = addr+(2**ADDR_WIDTH/2);
            data_b = RandomValsB[addr];
        end
        // 2 port read
        @(posedge clk);
        we_a = 0;
        we_b = 0;
        addr_a = 0;
        addr_b = (2**ADDR_WIDTH/2);
        @(posedge clk);
        for(int addr = 1; addr < 2**ADDR_WIDTH/2+1; addr++)begin
            addr_a = addr;
            addr_b = addr+(2**ADDR_WIDTH/2);
            @(posedge clk);
            if(RandomVals[addr-1] != q_a) begin
                errors++;
                $display("data_a Error! Expected: %d, Got: %d at address %h.", RandomVals[addr-1] ,q_a, addr_a); 
            end
            if(RandomValsB[addr-1] != q_b) begin
                errors++;
                $display("data_b Error! Expected: %d, Got: %d at address %h.", RandomValsB[addr-1] ,q_b, addr_b); 
            end
        end

        @(posedge clk);

        if (errors == 0) begin
            $display("Write and read for dual port is a pass!");
        end

        $stop;
    end

endmodule