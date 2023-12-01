
module sw_tb();
    reg clk;
    reg btn2;

    soc #( .ROMFILE("../../src/memdump/sw.mem")) soc_inst(
        .btn2(btn2),
        .clk(clk)
    );

    initial begin
        $dumpfile("sw_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_sw();
    begin
        $write("  test_sw: ");

        #22; // wait for sw to complete
        if(soc_inst.cpu_inst.regfile.registers[6] == 32'h0A)
            $display(" passed!");
        else
            $error("    x5 should be 32'h0A, but is %h", soc_inst.cpu_inst.regfile.registers[6]);

        #8;
    end
    endtask

     initial begin
        $display("sw_tb: starting tests");

        btn2 = 1;
        #1;
        btn2 = 0;
        #1;
        btn2 = 1;

        test_sw();

        $dumpoff;
        $finish;
    end
endmodule
