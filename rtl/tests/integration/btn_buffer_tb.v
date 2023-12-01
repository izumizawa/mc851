module btn_buffer_tb();
    reg clk;
    reg btn2;
    reg btn1;

    soc #( .ROMFILE("../../src/memdump/btn_buffer.mem")) soc_inst(
        .btn1(btn1),
        .btn2(btn2),
        .clk(clk)
    );

    initial begin
        $dumpfile("btn_buffer_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_btn_buffer();
    begin
        $write("  test_btn_buffer: ");
        btn1 = 1;
        #2;
        btn1 = 0;
        #2;
        btn1 = 1;

        #36 // wait for btn_buffer to complete
        if(soc_inst.cpu_inst.regfile.registers[6] == 32'h1)
            $display(" passed!");
        else
            $error("    x6 should be 32'h1, but is %h", soc_inst.cpu_inst.regfile.registers[6]);

        #8;
    end
    endtask

     initial begin
        $display("btn_buffer_tb: starting tests");

        btn2 = 1;
        #1;
        btn2 = 0;
        #1;
        btn2 = 1;

        test_btn_buffer();

        $dumpoff;
        $finish;
    end
endmodule
