module sltiu_tb();
    reg clk;
    reg btn2;

    soc #( .ROMFILE("../../src/memdump/sltiu.mem")) soc_inst(
        .btn2(btn2),
        .clk(clk)
    );

    initial begin
        $dumpfile("sltiu_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_sltiu();
    begin
        $write("  test_sltiu: ");

        #12; // wait for addi and sltiu to complete
        if(soc_inst.cpu_inst.regfile.registers[5] == 32'hFFFFFFFF && soc_inst.cpu_inst.regfile.registers[6] == 32'h00000000)
            $display(" passed!");
        else
            $error("    x6 should be 32'h00000000, but is %h", soc_inst.cpu_inst.regfile.registers[6]);

        #8;
    end
    endtask

     initial begin
        $display("sltiu_tb: starting tests");

        btn2 = 1;
        #1;
        btn2 = 0;
        #1;
        btn2 = 1;

        test_sltiu();

        $dumpoff;
        $finish;
    end
endmodule
