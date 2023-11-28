module srl_tb();
    reg clk;
    reg btn2;

    soc #( .ROMFILE("../../src/memdump/srl.mem")) soc_inst(
        .btn2(btn2),
        .clk(clk)
    );

    initial begin
        $dumpfile("srl_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_srl();
    begin
        $write("  test_srl: ");

        #14; // wait for srl to complete
        if(soc_inst.cpu_inst.regfile.registers[7] == 32'h00000009)
            $display(" passed!");
        else
            $error("    x7 should be 32'h00000009, but is %h", soc_inst.cpu_inst.regfile.registers[7]);

        #8;
    end
    endtask

     initial begin
        $display("srl_tb: starting tests");

        btn2 = 1;
        #1;
        btn2 = 0;
        #1;
        btn2 = 1;

        test_srl();

        $dumpoff;
        $finish;
    end
endmodule
