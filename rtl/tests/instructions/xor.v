module xor_tb();
    reg clk;
    reg reset_n;

    soc #( .ROMFILE("../../src/memdump/xor.mem")) soc_inst(
        .reset_n(reset_n),
        .clk(clk)
    );

    initial begin
        $dumpfile("xor_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_xor();
    begin
        $write("  test_xor: ");

        #10; // wait for xor to complete
        if(soc_inst.cpu_inst.regfile.registers[7] == 32'h0000000D)
            $display(" passed!");
        else
            $error("    x7 should be 32'h0000000D, but is %h", soc_inst.cpu_inst.regfile.registers[7]);

        #8;
    end
    endtask

     initial begin
        $display("xor_tb: starting tests");

        reset_n = 1;
        #1;
        reset_n = 0;
        #1;
        reset_n = 1;

        test_xor();

        $dumpoff;
        $finish;
    end
endmodule