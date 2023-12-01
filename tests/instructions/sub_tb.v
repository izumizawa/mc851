module sub_tb();
    reg clk;
    reg reset_n;

    soc #( .ROMFILE("../src/memdump/sub.mem")) soc_inst(
        .reset_n(reset_n),
        .clk(clk)
    );

    initial begin
        $dumpfile("sub_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_sub();
    begin
        $write("  test_sub: ");

        #14; // wait for first sub to complete
        if(soc_inst.cpu_core0.regfile.registers[7] == 32'h00000005)
            $display(" passed!");
        else
            $error("    x7 should be 32'h00000005, but is %h", soc_inst.cpu_core0.regfile.registers[7]);

        #8;
    end
    endtask

     initial begin
        $display("sub_tb: starting tests");

        reset_n = 1;
        #1;
        reset_n = 0;
        #1;
        reset_n = 1;

        test_sub();

        $dumpoff;
        $finish;
    end
endmodule
