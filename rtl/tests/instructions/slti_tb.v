module slti_tb();
    reg clk;
    reg btn2;

    soc #( .ROMFILE("../../src/memdump/slti.mem")) soc_inst(
        .btn2(btn2),
        .clk(clk)
    );

    initial begin
        $dumpfile("slti_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_slti();
    begin
        $write("  test_slti: ");

        #10; // wait for slti to complete
        if(soc_inst.cpu_inst.regfile.registers[5] == 32'h00000001)
            $display("\n    passed first scenario!");
        else
            $error("    x5 should be 32'h00000001, but is %h", soc_inst.cpu_inst.regfile.registers[5]);

        #10;

        if(soc_inst.cpu_inst.regfile.registers[5] == 32'h00000000)
            $display("\n    passed all scenarios!");
        else
            $error("    x5 should be 32'h00000000, but is %h", soc_inst.cpu_inst.regfile.registers[5]);
        #8;
    end
    endtask

     initial begin
        $display("slti_tb: starting tests");

        btn2 = 1;
        #1;
        btn2 = 0;
        #1;
        btn2 = 1;

        test_slti();

        $dumpoff;
        $finish;
    end
endmodule
