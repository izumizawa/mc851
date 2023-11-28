module add_tb();
    reg clk;
    reg btn2;

    soc #( .ROMFILE("../../src/memdump/add.mem")) soc_inst(
        .btn2(btn2),
        .clk(clk)
    );

    initial begin
        $dumpfile("add_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_add();
    begin
        $write("  test_add: ");

        #14; // wait for add to complete
        if(soc_inst.cpu_inst.regfile.registers[7] == 32'h00000051)
            $display(" passed!");
        else
            $error("    x7 should be 32'h00000051, but is %h", soc_inst.cpu_inst.regfile.registers[7]);

        #8;
    end
    endtask

     initial begin
        $display("add_tb: starting tests");

        btn2 = 1;
        #1;
        btn2 = 0;
        #1;
        btn2 = 1;

        test_add();

        $dumpoff;
        $finish;
    end
endmodule
