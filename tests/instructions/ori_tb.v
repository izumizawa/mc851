module ori_tb();
    reg clk;
    reg reset_n;

    soc #( .ROMFILE("../src/memdump/ori.mem")) soc_inst(
        .reset_n(reset_n),
        .clk(clk)
    );

    initial begin
        $dumpfile("ori_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_ori();
    begin
        $write("  test_ori: ");

        #10; // wait for ori to complete
        if(soc_inst.cpu_inst.regfile.registers[5] == 32'hFFFFFFFF)
            $display(" passed!");
        else
            $error("    x5 should be 32'hFFFFFFFF, but is %h", soc_inst.cpu_inst.regfile.registers[5]);

        #8;
    end
    endtask

     initial begin
        $display("ori_tb: starting tests");

        reset_n = 1;
        #1;
        reset_n = 0;
        #1;
        reset_n = 1;

        test_ori();

        $dumpoff;
        $finish;
    end
endmodule
