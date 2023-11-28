module sll_tb();
    reg clk;
    reg btn2;

    soc #( .ROMFILE("../../src/memdump/sll.mem")) soc_inst(
        .btn2(btn2),
        .clk(clk)
    );

    initial begin
        $dumpfile("sll_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_sll();
    begin
        $write("  test_sll: ");

        #14; // wait for sll to complete
        if(soc_inst.cpu_inst.regfile.registers[7] == 32'h000004C0)
            $display(" passed!");
        else
            $error("    x7 should be 32'h000004C0, but is %h", soc_inst.cpu_inst.regfile.registers[7]);

        #8;
    end
    endtask

     initial begin
        $display("sll_tb: starting tests");

        btn2 = 1;
        #1;
        btn2 = 0;
        #1;
        btn2 = 1;

        test_sll();

        $dumpoff;
        $finish;
    end
endmodule
