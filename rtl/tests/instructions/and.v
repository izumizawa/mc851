module and_tb();
    reg clk;
    reg reset_n;

    soc #( .ROMFILE("../../src/memdump/and.mem")) soc_inst(
        .reset_n(reset_n),
        .clk(clk)
    );

    initial begin
        $dumpfile("and_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_and();
    begin
        $write("  test_and: ");

        #10; // wait for and to complete
        if(soc_inst.cpu_inst.regfile.registers[7] == 32'h00000022)
            $display(" passed!");
        else
            $error("    x7 should be 32'h00000022, but is %h", soc_inst.cpu_inst.regfile.registers[7]);

        #8;
    end
    endtask

     initial begin
        $display("and_tb: starting tests");

        reset_n = 1;
        #1;
        reset_n = 0;
        #1;
        reset_n = 1;

        test_and();

        $dumpoff;
        $finish;
    end
endmodule