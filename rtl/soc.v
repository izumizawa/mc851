
module soc #(
    parameter ROMFILE="../src/memdump/addi.mem"
) (
    input clk,
    input reset_n,
    input btn1,
    input btn2,
    output uart_tx
);
    wire         mmu_mem_ready;
    wire [31:0]  mmu_data_out;
    wire         mmu_write_enable;
    wire         mmu_read_enable;
    wire         mmu_mem_signed_read;
    wire         mmu_signed_read;
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
        .mmu_data_in(mmu_data_in),
        .uart_data(data)
    );

    mmu #( .ROMFILE(ROMFILE)) mmu_inst (
        .clk(clk),
        .btn1(btn1),
        .btn2(btn2),
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

// TEST
reg [3:0] txState = 0;
reg [24:0] txCounter = 0;
reg [7:0] dataOut = 0;
reg [7:0] dataArray [0:3];
reg txPinRegister = 1;
reg [2:0] txBitNumber = 0;
reg [1:0] txByteCounter = 0;
wire [31:0] data;

// assign data = 32'b11111001101110011001101110011111;
assign uart_tx = txPinRegister;

localparam TX_STATE_IDLE = 0;
localparam TX_STATE_START_BIT = 1;
localparam TX_STATE_WRITE = 2;
localparam TX_STATE_STOP_BIT = 3;
localparam TX_STATE_DEBOUNCE = 4;

localparam DELAY_FRAMES = 234; // 27,000,000 (27Mhz) / 115200 Baud rate

always @(posedge clk) begin
    case (txState)
        TX_STATE_IDLE: begin
            if (btn1 == 0) begin
                txState <= TX_STATE_START_BIT;
                txCounter <= 0;
                txByteCounter <= 0;
                dataArray[0] <= data[31:24];
                dataArray[1] <= data[23:16];
                dataArray[2] <= data[15:8];
                dataArray[3] <= data[7:0];
            end
            else begin
                txPinRegister <= 1;
            end
        end
        TX_STATE_START_BIT: begin
            txPinRegister <= 0;
            if ((txCounter + 1) == DELAY_FRAMES) begin
                txState <= TX_STATE_WRITE;
                dataOut <= dataArray[txByteCounter];
                txBitNumber <= 0;
                txCounter <= 0;
            end else
                txCounter <= txCounter + 1;
        end
        TX_STATE_WRITE: begin
            txPinRegister <= dataOut[txBitNumber];
            if ((txCounter + 1) == DELAY_FRAMES) begin
                if (txBitNumber == 3'b111) begin
                    txState <= TX_STATE_STOP_BIT;
                end else begin
                    txState <= TX_STATE_WRITE;
                    txBitNumber <= txBitNumber + 1;
                end
                txCounter <= 0;
            end else
                txCounter <= txCounter + 1;
        end
        TX_STATE_STOP_BIT: begin
            txPinRegister <= 1;
            if ((txCounter + 1) == DELAY_FRAMES) begin
                if (txByteCounter == 2'b11) begin
                    txState <= TX_STATE_DEBOUNCE;
                end else begin
                    txByteCounter <= txByteCounter + 1;
                    txState <= TX_STATE_START_BIT;
                end
                txCounter <= 0;
            end else
                txCounter <= txCounter + 1;
        end
        TX_STATE_DEBOUNCE: begin
            if (txCounter == 25'b11111111111111111111) begin
                if (btn1 == 1)
                    txState <= TX_STATE_IDLE;
            end else
                txCounter <= txCounter + 1;
        end
    endcase
end

endmodule
