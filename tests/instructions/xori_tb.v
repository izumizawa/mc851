module xori_tb();
    reg clk;
    reg reset_n;

    soc #( .ROMFILE("../src/memdump/xori.mem")) soc_inst(
        .reset_n(reset_n),
        .clk(clk)
    );

    initial begin
        $dumpfile("xori_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_xori();
    begin
        $write("  test_xori: ");

        #10; // wait for andi to complete
        if(soc_inst.cpu_inst.regfile.registers[5] == 32'h00000001)
            $display(" passed!");
        else
            $error("    x5 should be 32'h00000001, but is %h", soc_inst.cpu_inst.regfile.registers[5]);

        #8;
    end
    endtask

     initial begin
        $display("xori_tb: starting tests");

        reset_n = 1;
        #1;
        reset_n = 0;
        #1;
        reset_n = 1;

        test_xori();

        $dumpoff;
        $finish;
    end
endmodule
