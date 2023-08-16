
module mem_module(clk, address, data_in, mem_write, mem_read, data_out);

input clk;
input[31:0] address;
input[31:0] data_in;

// 00 = not write
// 01 = write one byte
// 10 = write half word
// 11 = write word
input[1:0] mem_write;

// 000 = not read
// 001 = read one byte
// 010 = read byte unsigned
// 011 = read half word
// 100 = read half word unsigned
// 101 = read word
input[2:0] mem_read;

output reg [31:0] data_out;

always@(posedge clk) begin

// Instanciar e utilizar modula da RAM.

end

endmodule