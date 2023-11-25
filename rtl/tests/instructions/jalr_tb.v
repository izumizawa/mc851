module jalr_tb();
    reg clk;
    reg reset_n;

    soc #( .ROMFILE("../../src/memdump/jalr.mem")) soc_inst(
        .reset_n(reset_n),
        .clk(clk)
    );

    reg [31:0] jal_pc;

    initial begin
        $dumpfile("jalr_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_jalr();
    begin
        $write("  test_jalr: ");

        #10; // wait for jalr to complete
        jal_pc = soc_inst.cpu_inst.pc;
        #2;
        if(jal_pc == 32'h0000000C && soc_inst.cpu_inst.regfile.registers[1] == 32'h00000008)
            $display(" passed!");
        else
            $error("    PC should be 32'h0000000C and x1 should be 32'h00000008, but is %h and %h", jal_pc, soc_inst.cpu_inst.regfile.registers[1]);

        #8;
    end
    endtask

     initial begin
        $display("jalr_tb: starting tests");

        reset_n = 1;
        #1;
        reset_n = 0;
        #1;
        reset_n = 1;

        test_jalr();

        $dumpoff;
        $finish;
    end
endmodule
