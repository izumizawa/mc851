module add_tb();
    reg clk;
    reg reset_n;

    soc #( .ROMFILE("../src/memdump/add.mem")) soc_inst(
        .reset_n(reset_n),
        .clk(clk)
    );

    initial begin
        $dumpfile("add_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_add();
    begin
        $write("  test_add: ");

        #100; // wait for add to complete
        if(soc_inst.cpu_core0.regfile.registers[7] == 32'h00000051)
            $display(" passed!");
        else
            $error("    x7 should be 32'h00000051, but is %h", soc_inst.cpu_core0.regfile.registers[7]);

        #8;
    end
    endtask

     initial begin
        $display("add_tb: starting tests");

        reset_n = 1;
        #1;
        reset_n = 0;
        #1;
        reset_n = 1;

        test_add();

        $dumpoff;
        $finish;
    end
endmodule
