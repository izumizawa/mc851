module multiply_tb();
    reg clk;
    reg reset_n;

    soc #( .ROMFILE("../../src/memdump/multiply.mem")) soc_inst(
        .reset_n(reset_n),
        .clk(clk)
    );

    initial begin
        $dumpfile("multiply_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_multiply();
    begin
        $write("  test_multiply: ");

        #36 // wait for multiply to complete
        if(soc_inst.cpu_inst.regfile.registers[6] == 32'h4)
            $display(" passed!");
        else
            $error("    x6 should be 32'h2, but is %h", soc_inst.cpu_inst.regfile.registers[5]);

        #8;
    end
    endtask

     initial begin
        $display("multiply_tb: starting tests");

        reset_n = 1;
        #1;
        reset_n = 0;
        #1;
        reset_n = 1;

        test_multiply();

        $dumpoff;
        $finish;
    end
endmodule
