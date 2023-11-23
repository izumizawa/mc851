module andi_tb();
    reg clk;
    reg btn2;

    soc #( .ROMFILE("../../src/memdump/andi.mem")) soc_inst(
        .btn2(btn2),
        .clk(clk)
    );

    initial begin
        $dumpfile("andi_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_andi();
    begin
        $write("  test_andi: ");

        #10; // wait for andi to complete
        if(soc_inst.cpu_inst.regfile.registers[5] == 32'h00000000)
            $display(" passed!");
        else
            $error("    x5 should be 32'h00000000, but is %h", soc_inst.cpu_inst.regfile.registers[5]);

        #8;
    end
    endtask

     initial begin
        $display("andi_tb: starting tests");

        btn2 = 1;
        #1;
        btn2 = 0;
        #1;
        btn2 = 1;

        test_andi();

        $dumpoff;
        $finish;
    end
endmodule
