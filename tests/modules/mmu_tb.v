`include "../rtl/define.v"

module mmu_tb();
    reg clk;
    reg reset_n;
    reg write_enable;
    reg read_enable;
    reg [ 1:0] data_width;
    reg [31:0] virtual_address;
    reg [31:0] data_in;
    wire [31:0] data_out;
    wire mmu_ready;

    initial begin
        $dumpfile("mmu_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    mmu #( .ROMFILE("../src/memdump/addi.mem")) mmu_inst (
        .clk(clk),
        .reset_n(reset_n),
        .write_enable(write_enable),
        .read_enable(read_enable),
        .data_width(data_width),
        .virtual_address(virtual_address),
        .data_in(data_in),
        .data_out(data_out),
        .mmu_ready(mmu_ready)
    );

    task test_rom_read();
    begin
        $write("  test_rom_read:");
        write_enable = 0;
        read_enable = 1;
        data_width = `MMU_WIDTH_WORD;
        virtual_address = 0;
        data_in = 0;

        #2;
        while(mmu_ready !== 1) #2;

        if (data_out == 32'h00200293)
            $display(" passed!");
        else
            $error("    data_out should be 32'h00200293, but is %h", data_out);

        read_enable = 0;
        #8;
    end
    endtask

    // TODO: test is broken, need to be fixed. The issue is that the RAM is not
    // being read/written, behaviour descripted to make the UART demo work.
    task test_ram_read_and_write();
    begin
        $write("  test_ram_read_and_write:");
        write_enable = 1;
        read_enable = 0;
        data_width = `MMU_WIDTH_WORD;
        virtual_address = 32'h01000000; // First virtual_address of RAM
        data_in = 32'h69BABACA;

        #2;
        while(mmu_ready !== 1) #2;

        write_enable = 0;
        read_enable = 1;

        #2;
        while(mmu_ready !== 1) #2;

        if (data_out == 32'h69BABACA)
            $display(" passed!");
        else
            $error("    data_out should be 32'h69BABACA, but is %h", data_out);

        read_enable = 0;
        #8;
    end
    endtask

    initial begin
        $display("mmu_tb: starting tests");

        reset_n = 1;
        #1;
        reset_n = 0;
        #1;
        reset_n = 1;

        test_ram_read_and_write();
        test_rom_read();

        $dumpoff;
        $finish;
    end

endmodule
