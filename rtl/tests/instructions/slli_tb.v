module slli_tb();
    reg clk;
    reg btn2;

    soc #( .ROMFILE("../../src/memdump/slli.mem")) soc_inst(
        .btn2(btn2),
        .clk(clk)
    );

    initial begin
        $dumpfile("slli_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_slli();
    begin
        $write("  test_slli: ");

        #12; // wait for addi and slli to complete
        if(soc_inst.cpu_inst.regfile.registers[5] == 32'h00000001 && soc_inst.cpu_inst.regfile.registers[6] == 32'h00000002)
            $display(" passed!");
        else
            $error("    x6 should be 32'h00000002, but is %h", soc_inst.cpu_inst.regfile.registers[6]);

        #8;
    end
    endtask

     initial begin
        $display("slli_tb: starting tests");

        btn2 = 1;
        #1;
        btn2 = 0;
        #1;
        btn2 = 1;

        test_slli();

        $dumpoff;
        $finish;
    end
endmodule
