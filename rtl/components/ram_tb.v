module ram_component_tb();

    // Sinais de teste
    reg clk;
    reg read_enable;
    reg  [ 3:0] write_enable;
    reg  [31:0] address;
    reg  [31:0] data_in;
    wire [31:0] data_out;

    ram ram_inst (
        .clk(clk),
        .address(address),
        .data_in(data_in),
        .write_enable(write_enable),
        .read_enable(read_enable),
        .data_out(data_out)
    );

    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_write_and_read();
    begin
        $write("  test_write_and_read: ");

        clk = 0;
        address = 0;
        data_in = 0;
        write_enable = 4'b0000;
        read_enable = 0;
    
        #10
        write_enable = 4'b0001;
        address = 10;
        data_in = 42;

        #10
        write_enable = 4'b0000;

        #10
        read_enable = 1;
        address = 10;

        #10
        read_enable = 0;

        #10
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
        write_enable = 4'b0000;
        read_enable = 0;
    
        #10 
        write_enable = 4'b0001;
        address = 10;
        data_in = 42;

        #10
        write_enable = 4'b0000;

        #10
        read_enable = 1;
        address = 1;

        #10
        read_enable = 0;

        #10
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
