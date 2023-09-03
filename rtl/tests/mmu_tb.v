module mmu_tb();

    // Sinais de teste
    reg clk;
    reg [ 3:0] write_enable;
    reg [31:0] address;
    reg [31:0] data_in;
    wire [31:0] data_out;

    mmu mmu_inst (
        .clk(clk),
        .write_enable(write_enable),
        .address(address),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Clock will change in every 5 units
    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_rom_read();
    begin
        $write("  test_rom_read: ");

        clk = 0;
        write_enable =0;
        address = 0;
        data_in = 0;

        #2
        address = 10;
        data_in = 42;

        #2
        if (wait_if != 1)
            $display("wait_if should be 1 while mem is using the component");

        #2
        op_mem = 2'b0;

        #2
        if (wait_if != 0 && wait_mem != 0)
            $display("wait_if and wait_mem should be 0 while the component is not in use");

        #2
        op_mem = 2'b10;
        address = 10;

        #31
        if (wait_if != 1)
            $display("wait_if should be 1 while mem is using the component");

        #40
        op_mem = 2'b0;

        #50
        if (data_out != 42)
            $display("data_out should be 00000000000000000000000000101010, but is %b", data_out);
        else
            $display("passed!");
        end
    endtask

    initial begin
        $display("memory_control_tb: starting tests");
        test_write_and_read_mem();
        test_read_if();
        $finish;
    end

endmodule
