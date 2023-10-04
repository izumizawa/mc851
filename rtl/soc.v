`include "cpu.v"
`include "mmu.v"

module soc #(
    parameter ROMFILE=""
) (
    input clk,
    input reset_n
);
    wire         mmu_mem_ready;
    wire [31:0]  mmu_data_out;
    wire         mmu_write_enable;
    wire         mmu_read_enable;
    wire         mmu_mem_signed_read;
    wire [ 1:0]  mmu_mem_data_width;
    wire [31:0]  mmu_address;
    wire [31:0]  mmu_data_in;

    cpu cpu_inst (
        .clk (clk),
        .reset_n (reset_n),
        .mmu_mem_ready(mmu_mem_ready),
        .mmu_data_out(mmu_data_out),
        .mmu_write_enable(mmu_write_enable),
        .mmu_read_enable(mmu_read_enable),
        .mmu_mem_signed_read(mmu_signed_read),
        .mmu_mem_data_width(mmu_mem_data_width),
        .mmu_address(mmu_address),
        .mmu_data_in(mmu_data_in)
    );

    mmu #( .ROMFILE(ROMFILE)) mmu_inst (
        .clk(clk),
        .reset_n(reset_n),
        .write_enable(mmu_write_enable),
        .read_enable(mmu_read_enable),
        .mem_signed_read(mmu_signed_read),
        .mem_data_width(mmu_mem_data_width),
        .address(mmu_address),
        .data_in(mmu_data_in),
        .data_out(mmu_data_out),
        .mem_ready(mmu_mem_ready)
    );
endmodule
