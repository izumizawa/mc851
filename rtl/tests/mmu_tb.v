`include "../define.v"

module mmu_tb();

    // Sinais de teste
    reg clk;
    reg reset;
    reg write_enable;
    reg read_enable;
    reg mem_signed_read;
    reg [ 1:0] mem_data_width;
    reg [31:0] address;
    reg [31:0] data_in;
    wire [31:0] data_out;
    wire mem_ready;

    // Clock will change in every unit
    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    mmu #( .ROMFILE("../../src/memdump/test.mem")) mmu_inst (
        .clk(clk),
        .reset(reset),
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
        clk = 0;
        reset = 0;
        write_enable = 0;
        read_enable = 1;
        mem_signed_read = 0;
        mem_data_width = `MMU_WIDTH_WORD;
        address = 0;
        data_in = 0;

        // Esperar mmu sinalizar que está pronta
        while(mem_ready !== 1) #2;

        if (data_out == 32'h00200293)
            $display(" passed!");
        else
            $error("    data_out should be 32'h00200293, but is %h", data_out);

        #8;
    end
    endtask

    task test_ram_read_and_write();
    begin
        $write("  test_ram_read_and_write:");
        clk = 0;
        reset = 0;
        write_enable = 1;
        read_enable = 0;
        mem_signed_read = 0;
        mem_data_width = `MMU_WIDTH_WORD;
        address = 32'h01000000; // First address of RAM
        data_in = 32'h69BABACA;

        while(mem_ready !== 1) #2;
        #2; // TODO: Commitar em memória 1 ciclo de clock antes

        write_enable = 0;
        read_enable = 1;

        while(mem_ready !== 1) #2;

        if (data_out == 32'h69BABACA)
            $display(" passed!");
        else
            $error("    data_out should be 32'h69BABACA, but is %h", data_out);

        read_enable = 0;
        #8;
    end
    endtask

    initial begin
        $display("memory_control_tb: starting tests");
        test_ram_read_and_write();
        test_rom_read();
        $finish;
    end

endmodule
