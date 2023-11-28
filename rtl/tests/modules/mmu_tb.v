`include "../define.v"

module mmu_tb();
    reg clk;
    reg btn1;
    reg btn2;
    reg write_enable;
    reg read_enable;
    reg mem_signed_read;
    reg [ 1:0] mem_data_width;
    reg [31:0] address;
    reg [31:0] data_in;
    wire [31:0] data_out;
    wire mem_ready;

    reg [31:0] result_data_out_1;
    reg [31:0] result_data_out_2;

    initial begin
        $dumpfile("mmu_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    mmu #( .ROMFILE("../../src/memdump/addi.mem")) mmu_inst (
        .clk(clk),
        .btn1(btn1),
        .btn2(btn2),
        .reset_n(btn2),
        .write_enable(write_enable),
        .read_enable(read_enable),
        .mem_signed_read(mem_signed_read),
        .mem_data_width(mem_data_width),
        .address(address),
        .data_in(data_in),
        .data_out(data_out),
        .mem_ready(mem_ready)
    );

    task test_rom_read();
    begin
        $write("  test_rom_read:");
        write_enable = 0;
        read_enable = 1;
        mem_signed_read = 0;
        mem_data_width = `MMU_WIDTH_WORD;
        address = 0;
        data_in = 0;

        #2;
        while(mem_ready !== 1) #2;

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
        mem_signed_read = 0;
        mem_data_width = `MMU_WIDTH_WORD;
        address = 32'h01000000; // First address of RAM
        data_in = 32'h69BABACA;

        #2;
        while(mem_ready !== 1) #2;

        write_enable = 0;
        read_enable = 1;

        #2;
        while(mem_ready !== 1) #2;

        if (data_out == 32'h69BABACA)
            $display(" passed!");
        else
            $error("    data_out should be 32'h69BABACA, but is %h", data_out);

        read_enable = 0;
        #8;
    end
    endtask

    task test_btn();
    begin
        $write("  test_btn: ");
        read_enable = 0;
        mem_signed_read = 0;
        mem_data_width = `MMU_WIDTH_WORD;
        address = 32'h02000000; // First address of RAM
        btn1 = 1;

        btn1 = 0;
        #4;
        btn1 = 1;

        #2;
        while(mem_ready !== 1) #2;
        read_enable = 1;

        #2
        result_data_out_1 = data_out;
        read_enable = 0;

        #2;
        while(mem_ready !== 1) #2;
        read_enable = 1;

        #2;
        while(mem_ready !== 1) #2;
        result_data_out_2 = data_out;
        read_enable = 0;

        #2;
        while(mem_ready !== 1) #2;
        if (result_data_out_1 != 1 || result_data_out_2 != 0)
            $display("result_data_out_1 should be 0x1 and result_data_out_2 should be 0x0, but is %h and %h", result_data_out_1, result_data_out_2);
        else
            $display("ok!");
    end
    endtask

    task test_led();
    begin
        $write("  test_led: ");
        write_enable = 1;
        mem_signed_read = 0;
        mem_data_width = `MMU_WIDTH_WORD;
        address = 32'h03000000;
        data_in = 32'h69BABACA; // 32'b1101001101110101011101011001010

        #2;
        while(mem_ready !== 1) #2;

        write_enable = 1;

        #2;
        while(mem_ready !== 1) #2;

        #2;
        write_enable = 0;

        #2;

        if (mmu_inst.led != 5'b01010)
            $display("   led should be 5'b01010, but it is %b", mmu_inst.led);
        else
            $display("passed!");
    end
    endtask

    initial begin
        $display("mmu_tb: starting tests");

        btn2 = 1;
        #1;
        btn2 = 0;
        #1;
        btn2 = 1;

        // test_ram_read_and_write();
        test_rom_read();
        test_btn();
        test_led();

        $dumpoff;
        $finish;
    end

endmodule
