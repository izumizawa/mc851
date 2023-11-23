module srai_tb();
    reg clk;
    reg btn2;

    soc #( .ROMFILE("../../src/memdump/srai.mem")) soc_inst(
        .btn2(btn2),
        .clk(clk)
    );

    initial begin
        $dumpfile("srai_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_srai();
    begin
        $write("  test_srai: ");

        #12; // wait for addi and srai to complete
        if(soc_inst.cpu_inst.regfile.registers[5] == 32'hFFFFFFFE && soc_inst.cpu_inst.regfile.registers[6] == 32'hFFFFFFFF)
            $display(" passed!");
        else
            $error("    x6 should be 32'h00000001, but is %h", soc_inst.cpu_inst.regfile.registers[6]);

        #8;
    end
    endtask

     initial begin
        $display("srai_tb: starting tests");

        btn2 = 1;
        #1;
        btn2 = 0;
        #1;
        btn2 = 1;

        test_srai();

        $dumpoff;
        $finish;
    end
endmodule
