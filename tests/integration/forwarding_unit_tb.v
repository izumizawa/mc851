module forwarding_unit_tb();
    reg clk;
    reg reset_n;

    soc #( .ROMFILE("../../src/memdump/forwarding_unit.mem")) soc_inst(
        .reset_n(reset_n),
        .clk(clk)
    );

    initial begin
        $dumpfile("forwarding_unit_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_forwarding_unit();
    begin
        $write("  test_forwarding_unit: ");

        #12; // wait for forwarding_unit to complete
        if(soc_inst.cpu_inst.regfile.registers[5] == 32'h4)
            $display(" passed!");
        else
            $error("    x5 should be 32'h4, but is %h", soc_inst.cpu_inst.regfile.registers[5]);

        #8;
    end
    endtask

     initial begin
        $display("forwarding_unit_tb: starting tests");

        reset_n = 1;
        #1;
        reset_n = 0;
        #1;
        reset_n = 1;

        test_forwarding_unit();

        $dumpoff;
        $finish;
    end
endmodule
