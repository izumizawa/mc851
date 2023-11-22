module bgeu_tb();
    reg clk;
    reg reset_n;

    soc #( .ROMFILE("../../src/memdump/bgeu.mem")) soc_inst(
        .reset_n(reset_n),
        .clk(clk)
    );

    initial begin
        $dumpfile("bgeu_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_bgeu();
    begin
        $write("  test_bgeu: ");

        #12; // wait for bgeu to complete
        if(soc_inst.cpu_inst.regfile.registers[5] == 32'hFFFFFFFF && soc_inst.cpu_inst.regfile.registers[6] == 32'h0 && soc_inst.cpu_inst.pc == 32'h0)
            $display(" passed!");
        else
            $error("    pc should be 32'h0, but is %h", soc_inst.cpu_inst.pc);

        #8;
    end
    endtask

     initial begin
        $display("bgeu_tb: starting tests");

        reset_n = 1;
        #1;
        reset_n = 0;
        #1;
        reset_n = 1;

        test_bgeu();

        $dumpoff;
        $finish;
    end
endmodule
