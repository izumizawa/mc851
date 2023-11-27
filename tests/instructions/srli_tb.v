module srli_tb();
    reg clk;
    reg reset_n;

    soc #( .ROMFILE("../src/memdump/srli.mem")) soc_inst(
        .reset_n(reset_n),
        .clk(clk)
    );

    initial begin
        $dumpfile("srli_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_srli();
    begin
        $write("  test_srli: ");

        #12; // wait for addi and srli to complete
        if(soc_inst.cpu_inst.regfile.registers[5] == 32'h00000002 && soc_inst.cpu_inst.regfile.registers[6] == 32'h00000001)
            $display(" passed!");
        else
            $error("    x6 should be 32'h00000001, but is %h", soc_inst.cpu_inst.regfile.registers[6]);

        #8;
    end
    endtask

     initial begin
        $display("srli_tb: starting tests");

        reset_n = 1;
        #1;
        reset_n = 0;
        #1;
        reset_n = 1;

        test_srli();

        $dumpoff;
        $finish;
    end
endmodule
