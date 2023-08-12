
module ram(clk, address, data_in, mem_write, mem_read, data_out);

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

// [mem word size] mem [mem size]
reg [31:0] mem [0:65536];

initial begin data_out = 32'b0; end

always@(posedge clk)
begin
if (mem_write != 2'b0 ) begin
     mem[address] = data_in;
end

if (mem_read != 3'b0) begin
    data_out = mem[address];
    end
end

endmodule
