module sra_tb();
    reg clk;
    reg reset_n;

    soc #( .ROMFILE("../../src/memdump/sra.mem")) soc_inst(
        .reset_n(reset_n),
        .clk(clk)
    );

    initial begin
        $dumpfile("sra_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_sra();
    begin
        $write("  test_sra: ");

        #10; // wait for sra to complete
        if(soc_inst.cpu_inst.regfile.registers[7] == 32'00000004)
            $display(" passed!");
        else
            $error("    x7 should be 32'h00000004, but is %h", soc_inst.cpu_inst.regfile.registers[7]);

        #8;
    end
    endtask

     initial begin
        $display("sra_tb: starting tests");

        reset_n = 1;
        #1;
        reset_n = 0;
        #1;
        reset_n = 1;

        test_sra();

        $dumpoff;
        $finish;
    end
endmodule