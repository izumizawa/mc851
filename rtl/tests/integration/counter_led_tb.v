module counter_led_tb();
    reg clk;
    reg btn2;
    reg btn1;

    soc #( .ROMFILE("../../src/memdump/counter_led.mem")) soc_inst(
        .btn1(btn1),
        .btn2(btn2),
        .clk(clk)
    );

    initial begin
        $dumpfile("counter_led_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_counter_led();
    begin
        $write("  test_counter_led: ");
        btn1 = 1;
        #2;
        btn1 = 0;
        #2;
        btn1 = 1;

        #36 // wait for counter_led to complete
        if(soc_inst.led_inst.led_data_out == 6'b111110)
            $display(" passed!");
        else
            $error("   soc_inst.led_inst.led_data_out should be 1'b1, but is %h", soc_inst.led_inst.led_data_out);

        #8;
    end
    endtask

     initial begin
        $display("counter_led_tb: starting tests");

        btn2 = 1;
        #1;
        btn2 = 0;
        #1;
        btn2 = 1;

        test_counter_led();

        $dumpoff;
        $finish;
    end
endmodule
