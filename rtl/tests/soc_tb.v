`include "../soc.v"
`default_nettype none

module soc_tb();
    reg clock,
    reg reset,
    reg         mmu_mem_ready,
    reg [31:0]  mmu_data_out,
    reg         mmu_write_enable,
    reg         mmu_read_enable,
    reg         mmu_mem_signed_read,
    reg [ 1:0]  mmu_mem_data_width,
    reg [31:0]  mmu_address,
    reg [31:0]  mmu_data_in,

    soc soc_inst(
        .rst_n (rst_n),
        .clk (clk),
    );

    initial begin
        $dumpfile("soc_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    task test_addi();
    begin
        
    end
    endtask
endmodule
