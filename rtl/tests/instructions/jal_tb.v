module jal_tb();
    reg clk;
    reg reset_n;

    soc #( .ROMFILE("../../src/memdump/jal.mem")) soc_inst(
        .reset_n(reset_n),
        .clk(clk)
    );

    reg [31:0] jal_pc;

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
        jal_pc = soc_inst.cpu_inst.pc;
        #2;
        if(jal_pc == 32'h00000008 && soc_inst.cpu_inst.regfile.registers[1] == 32'h00000004)
            $display(" passed!");
        else
            $error("    PC should be 32'h00000008 and x1 should be 32'h00000004, but is %h and %h", jal_pc, soc_inst.cpu_inst.regfile.registers[1]);

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
