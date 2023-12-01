module slt_tb();
    reg clk;
    reg reset_n;

    soc #( .ROMFILE("../src/memdump/slt.mem")) soc_inst(
        .reset_n(reset_n),
        .clk(clk)
    );

    initial begin
        $dumpfile("slt_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_slt();
    begin
        $write("  test_slt: ");

        #14; // wait for slt to complete
        if(soc_inst.cpu_core0.regfile.registers[7] == 32'h00000001)
            $display(" passed!");
        else
            $error("    x7 should be 32'h00000001, but is %h", soc_inst.cpu_core0.regfile.registers[7]);

        #8;
    end
    endtask

     initial begin
        $display("slt_tb: starting tests");

        reset_n = 1;
        #1;
        reset_n = 0;
        #1;
        reset_n = 1;

        test_slt();

        $dumpoff;
        $finish;
    end
endmodule
