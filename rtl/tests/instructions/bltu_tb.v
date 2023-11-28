module bltu_tb();
    reg clk;
    reg btn2;

    soc #( .ROMFILE("../../src/memdump/bltu.mem")) soc_inst(
        .btn2(btn2),
        .clk(clk)
    );

    initial begin
        $dumpfile("bltu_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_bltu();
    begin
        $write("  test_bltu: ");

        #12; // wait for bltu to complete
        if(soc_inst.cpu_inst.regfile.registers[5] == 32'hFFFFFFFF && soc_inst.cpu_inst.regfile.registers[6] == 32'h0 && soc_inst.cpu_inst.pc == 32'h0)
            $display(" passed!");
        else
            $error("    pc should be 32'h0, but is %h", soc_inst.cpu_inst.pc);

        #8;
    end
    endtask

     initial begin
        $display("bltu_tb: starting tests");

        btn2 = 1;
        #1;
        btn2 = 0;
        #1;
        btn2 = 1;

        test_bltu();

        $dumpoff;
        $finish;
    end
endmodule
