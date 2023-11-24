module jal_tb();
    reg clk;
    reg reset_n;

    soc #( .ROMFILE("../../src/memdump/jal.mem")) soc_inst(
        .reset_n(reset_n),
        .clk(clk)
    );

    initial begin
        $dumpfile("jal_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_jal();
    begin
        $write("  test_jal: ");

        #8; // wait for jal to complete
        if(soc_inst.cpu_inst.pc == 32'h00000008)
            $display(" passed!");
        else
            $error("    PC should be 32'h00000008, but is %h", soc_inst.cpu_inst.pc);

        #8;
    end
    endtask

     initial begin
        $display("jal_tb: starting tests");

        reset_n = 1;
        #1;
        reset_n = 0;
        #1;
        reset_n = 1;

        test_jal();

        $dumpoff;
        $finish;
    end
endmodule
