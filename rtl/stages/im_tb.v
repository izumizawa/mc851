module IM_TestBench();
    parameter CLK_PERIOD = 10;

    reg [31:0] address;
    reg [31:0] mem;
    wire [31:0] instruction;

    InstructionMemory uut(
        .address(address),
        .mem(mem),
        .instruction(instruction)
    );

    // Clock generation
    reg clk;
    always #(CLK_PERIOD / 2)
    begin
        clk = ~clk;
    end

    task test_IM();
    begin
        clk = 0;
        address = 32'b0;
        mem = 32'hF0F0_F0F0;

        #(CLK_PERIOD * 10);

        if(instruction === 32'hF0F0_F0F0)
        begin
            $display("SUCCESS: Test 1 passed");
        end

        address = 32'b1;
        mem = 32'h0F0F_0F0F;

        #(CLK_PERIOD * 10);

        if(instruction === 32'h0F0F_0F0F)
        begin
            $display("SUCCESS: Test 2 passed");
        end

        $finish;
    end
    endtask

    initial begin
        $display("Starting Instruction Memory tests");
        test_IM();
    end

endmodule