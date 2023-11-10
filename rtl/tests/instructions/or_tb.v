module or_tb();
    reg clk;
    reg reset_n;

    soc #( .ROMFILE("../../src/memdump/or.mem")) soc_inst(
        .reset_n(reset_n),
        .clk(clk)
    );

    initial begin
        $dumpfile("or_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_or();
    begin
        $write("  test_or: ");

        #14; // wait for or to complete
        if(soc_inst.cpu_inst.regfile.registers[7] == 32'h0000002F)
            $display(" passed!");
        else
            $error("    x7 should be 32'h0000002F, but is %h", soc_inst.cpu_inst.regfile.registers[7]);

        #8;
    end
    endtask

     initial begin
        $display("or_tb: starting tests");

        reset_n = 1;
        #1;
        reset_n = 0;
        #1;
        reset_n = 1;

        test_or();

        $dumpoff;
        $finish;
    end
endmodule
