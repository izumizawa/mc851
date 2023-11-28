module sra_tb();
    reg clk;
    reg btn2;

    soc #( .ROMFILE("../../src/memdump/sra.mem")) soc_inst(
        .btn2(btn2),
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

        #14; // wait for sra to complete
        if(soc_inst.cpu_inst.regfile.registers[7] == 32'h00000004)
            $display(" passed!");
        else
            $error("    x7 should be 32'h00000004, but is %h", soc_inst.cpu_inst.regfile.registers[7]);

        #8;
    end
    endtask

     initial begin
        $display("sra_tb: starting tests");

        btn2 = 1;
        #1;
        btn2 = 0;
        #1;
        btn2 = 1;

        test_sra();

        $dumpoff;
        $finish;
    end
endmodule
