module memory_control_tb();

    // Sinais de teste
    reg clk;
    reg [31:0] address;
    reg [31:0] data_in;

    reg [1:0] op_mem;
    reg op_if;

    wire [31:0] data_out;
    wire wait_mem;
    wire wait_if;

    memory_control memory_control_inst (
        .clk(clk),
        .address(address),
        .data_in(data_in),
        .op_mem(op_mem),
        .op_if(op_if),
        .data_out(data_out),
        .wait_mem(wait_mem),
        .wait_if(wait_if)
    );

    // Clock will change in every 5 units
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task test_write_and_read_mem();
    begin
        $write("  test_write_and_read_mem: ");

        clk = 0;
        address = 0;
        data_in = 0;
        op_mem = 2'b0;
        op_if = 1'b0;

        #10 
        op_mem = 2'b10;
        address = 10;
        data_in = 42;

        #11
        if (wait_if != 1)
            $display("wait_if should be 1 while mem is using the component");

        #20
        op_mem = 2'b0;

        #21
        if (wait_if != 0 && wait_mem != 0)
            $display("wait_if and wait_mem should be 0 while the component is not in use");

        #30
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

    task test_read_if();
    begin
        $write("  test_read_if: ");

        clk = 0;
        address = 0;
        data_in = 0;
        op_mem = 2'b0;
        op_if = 1'b0;

        #10 
        op_mem = 2'b10;
        address = 10;
        data_in = 102;

        #11
        if (wait_if != 1)
            $display("wait_if should be 1 while mem is using the component");

        #20
        op_mem = 2'b0;

        #21
        if (wait_if != 0 && wait_mem != 0)
            $display("wait_if and wait_mem should be 0 while the component is not in use");

        #30
        op_if = 1'b1;
        address = 10;

        #31
        if (wait_mem != 1)
            $display("wait_mem should be 1 while if is using the component");

        #40
        op_if = 2'b0;

        #50
        if (data_out != 102)
            $display("data_out should be 00000000000000000000000001100110, but is %b", data_out);
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