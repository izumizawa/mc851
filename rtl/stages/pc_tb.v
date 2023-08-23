module PC_TestBench();
    parameter CLK_PERIOD = 10;

    reg reset_tb, clock_tb, load_tb;
    reg [31:0] nextInstruction_tb;
    wire [31:0] currentInstruction_tb;

    PC uut(
        .nextInstruction(nextInstruction_tb),
        .currentInstruction(currentInstruction_tb),
        .reset(reset_tb),
        .clock(clock_tb),
        .load(load_tb)
    );

    // Clock generation
    always #(CLK_PERIOD / 2)
    begin
        clock_tb = ~clock_tb;
    end

    task test_PC();
    begin
        clock_tb = 0;
        reset_tb = 1;
        load_tb = 0;
        nextInstruction_tb = 32'h0000_0004;

        // Reset sequence
        #(CLK_PERIOD * 5);
        reset_tb = 0;

        // Wait for a few clock cycles
        #(CLK_PERIOD * 10);

        // Enable PC
        load_tb = 1;

        // Test 1
        #(CLK_PERIOD * 10) 
        if(currentInstruction_tb === 32'h0000_0004) 
        begin
            $display("SUCCESS: Test 1 passed");
        end

        nextInstruction_tb <= 32'h0000_0008;
        // Disable PC
        load_tb = 0;

        // Test 2
        #(CLK_PERIOD * 10) 
        if((currentInstruction_tb !== 32'h0000_0008) && (currentInstruction_tb === 32'h0000_0004))
        begin
            $display("SUCCESS: Test 2 passed");
        end
    end
    endtask

    initial begin
        $display("Starting Program Counter tests");
        test_PC();
    end

endmodule