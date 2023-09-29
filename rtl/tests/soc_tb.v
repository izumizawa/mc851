module soc_tb();
    reg clk;
    reg reset_n;

    soc soc_inst(
        .reset_n(reset_n),
        .clk(clk)
    );

    initial begin
        $dumpfile("soc_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_addi();
    begin
        $write("  test_write_and_read: ");
        reset_n = 1;
        #1;
        reset_n = 0;
        #1;
        reset_n = 1;
        #42; // wait for addi to be complete
        if(soc_inst.cpu_inst.regfile.registers[5] == 32'h2)
            $display(" passed!");
        else
            $error("    data_out should be 32'h2, but is %h", soc_inst.cpu_inst.regfile.registers[5]);
    end
    endtask

     initial begin
        $display("soc_tb: starting tests");
        test_addi();
        $finish;
    end
endmodule
