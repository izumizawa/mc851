module srl_tb();
    reg clk;
    reg reset_n;

    soc #( .ROMFILE("../../src/memdump/srl.mem")) soc_inst(
        .reset_n(reset_n),
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

        #10; // wait for srl to complete
        if(soc_inst.cpu_inst.regfile.registers[7] == 32'00000009)
            $display(" passed!");
        else
            $error("    x7 should be 32'h00000009, but is %h", soc_inst.cpu_inst.regfile.registers[7]);

        #8;
    end
    endtask

     initial begin
        $display("srl_tb: starting tests");

        reset_n = 1;
        #1;
        reset_n = 0;
        #1;
        reset_n = 1;

        test_srl();

        $dumpoff;
        $finish;
    end
endmodule