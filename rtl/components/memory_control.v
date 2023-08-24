module memory_control (
    input clk,
    input[31:0] address,
    input[31:0] data_in,

    // 00 = nothing
    // 01 = read
    // 10 = write
    input[1:0] op_mem,

    // 0 = nothin
    // 1 = read
    input op_if,

    // IF should wait (MEM is using)
    output reg wait_if,
    // MEM should wait (IF is using)
    output reg wait_mem,

    output reg [31:0] data_out
);

    // [mem word size] mem [mem size]
    // 2048(2^11) values of 32 bits
    reg [31:0] mem [0: 2047];

    always @(posedge clk) begin
        if (op_mem != 2'b0) begin
            wait_if <= 1;
            wait_mem <= 0;
            
            if (op_mem == 2'b01) begin
                data_out <= mem[address];
            end else if (op_mem == 2'b10) begin
                mem[address] <= data_in;
            end
        end else if (op_if != 1'b0) begin
            wait_mem <= 1;
            wait_if <= 0;

            if (op_if == 1'b1) begin
                data_out <= mem[address];
            end
        end else begin
            wait_mem <= 0;
            wait_if <= 0;
        end
    end

endmodule
