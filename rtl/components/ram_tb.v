module ram_component_tb();

    // Sinais de teste
    reg clk;
    reg [2:0] mem_read;
    reg [1:0] mem_write;
    reg [31:0] address;
    reg [31:0] data_in;
    wire [31:0] data_out;

    ram ram_inst (
        .clk(clk),
        .address(address),
        .data_in(data_in),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .data_out(data_out)
    );

    // Clock will change in every 5 units
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task test_write_and_read();
    begin
        $write("  test_write_and_read: ");

        clk = 0;
        address = 0;
        data_in = 0;
        mem_write = 0;
        mem_read = 0;
    
        #10 
        mem_write = 1;
        address = 10;
        data_in = 42;

        #20
        mem_write = 0;

        #30
        mem_read = 1;
        address = 10;

        #40
        mem_read = 0;

        #50
        if (data_out != 42)
            $display("data_out should be 00000000000000000000000000101010, but is %b", data_out);
        else
            $display("passed!");
        end
    endtask

    task test_invalid_address();
    begin
        $write("  test_invalid_address: ");

        clk = 0;
        address = 0;
        data_in = 0;
        mem_write = 0;
        mem_read = 0;
    
        #10 
        mem_write = 1;
        address = 10;
        data_in = 42;

        #20
        mem_write = 0;

        #30
        mem_read = 1;
        address = 1;

        #40
        mem_read = 0;

        #50
        if (data_out != 32'bx)
            $display("data_out should be 32'bx, but is %b", data_out);
        else
            $display("passed!");
    end
    endtask

    initial begin
        $display("ram_component_tb: starting tests");
        test_write_and_read();
        test_invalid_address();
        $finish;
    end

endmodule