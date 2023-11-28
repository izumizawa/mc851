
module addi_tb();
    reg clk;
    reg btn2;

    soc #( .ROMFILE("../../src/memdump/addi.mem")) soc_inst(
        .btn2(btn2),
        .clk(clk)
    );

    initial begin
        $dumpfile("addi_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_addi();
    begin
        $write("  test_addi: ");

        #10; // wait for addi to complete
        if(soc_inst.cpu_inst.regfile.registers[5] == 32'h2)
            $display(" passed!");
        else
            $error("    x5 should be 32'h2, but is %h", soc_inst.cpu_inst.regfile.registers[5]);

        #8;
    end
    endtask

     initial begin
        $display("addi_tb: starting tests");

        btn2 = 1;
        #1;
        btn2 = 0;
        #1;
        btn2 = 1;

        test_addi();

        $dumpoff;
        $finish;
    end
endmodule
