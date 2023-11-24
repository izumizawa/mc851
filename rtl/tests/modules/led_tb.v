module led_tb();

    reg clk;
    reg write_enable;
    reg [5:0] data_in;
    wire [5:0] led;

    reg [5:0] led_data_out_1;
    reg [5:0] led_data_out_2;

    led led_inst (
        .clk(clk),
        .write_enable(write_enable),
        .data_in(data_in),
        .led(led)
    );

    initial begin
        $dumpfile("led_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_write_led();
    begin
        $write("  test_write_led: ");

        clk = 0;
        write_enable = 0;
        data_in = 5'b0;

        #10
        write_enable = 1;
        data_in = 5'b00001;
        led_data_out_1 = led;

        if (led_data_out_1 != 5'b00001)
            $display("   led should be 5'b00001, but it is %b", led_data_out_1);
        else
            $display("passed!");

    end
    endtask

    task test_overwrite_led();
    begin
        $write("  test_overwrite_led: ");

        clk = 0;
        write_enable = 0;
        data_in = 5'b0;

        #10
        write_enable = 1;
        data_in = 5'b0;
        led_data_out_2 = led;

        #10
        write_enable = 1;
        data_in = 5'b01010;
        led_data_out_2 = led;

        if (led_data_out_2 != 5'b0)
            $display("   led should be 5'b01010, but it is %b", led_data_out_2);
        else
            $display("passed!");
    end
    endtask

    initial begin
        $display("led_tb: starting tests");

        test_write_led();
        test_overwrite_led();

        $dumpoff;
        $finish;
    end

endmodule
