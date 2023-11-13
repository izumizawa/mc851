module beq_tb();
    reg clk;
    reg reset_n;

    soc #( .ROMFILE("../../src/memdump/beq.mem")) soc_inst(
        .reset_n(reset_n),
        .clk(clk)
    );

    initial begin
        $dumpfile("beq_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_beq();
    begin
        $write("  test_beq: ");

        #10; // wait for beq to complete
        if(soc_inst.cpu_inst.regfile.registers[5] == 32'h2 && soc_inst.cpu_inst.pc == 32'h0)
            $display(" passed!");
        else
            $error("    pc should be 32'h0, but is %h", soc_inst.cpu_inst.pc);

        #8;
    end
    endtask

     initial begin
        $display("beq_tb: starting tests");

        reset_n = 1;
        #1;
        reset_n = 0;
        #1;
        reset_n = 1;

        test_beq();

        $dumpoff;
        $finish;
    end
endmodule
