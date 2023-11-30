
module soc #(
    parameter ROMFILE="../src/memdump/addi.mem"
) (
    input clk,
    input btn1,
    input btn2,
    output [5:0] led,
    output uart_tx
);
    wire         mmu_write_enable;
    wire         mmu_mem_signed_read;
    wire         mmu_signed_read;
    wire [31:0]  mmu_data_in;

    localparam ROM_ADDR_WIDTH = 8;
    wire [ROM_ADDR_WIDTH-1:0]  rom_address;
    wire         rom_read_enable;
    wire [31:0]  rom_data_out;


    cpu #(
        .ROM_ADDR_WIDTH(ROM_ADDR_WIDTH)
    ) cpu_inst (
        .clk (clk),
        .reset_n (btn2),
        .rom_data_out(rom_data_out),
        .mmu_write_enable(mmu_write_enable),
        .rom_read_enable(rom_read_enable),
        .mmu_mem_signed_read(mmu_signed_read),
        .rom_address(rom_address),
        .mmu_data_in(mmu_data_in),
        .uart_data(data)
    );


    rom #(
        .ADDR_WIDTH(ROM_ADDR_WIDTH),
        .ROMFILE(ROMFILE)
    ) rom_inst (
        .clk            (clk            ),
        .read_enable    (rom_read_enable),
        .address        (rom_address    ),
        .data_out       (rom_data_out   )
    );

/* ------------ UART ------------- */

// UART TEST
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
            end else begin
                txCounter <= txCounter + 1;
            end
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
            end else begin
                txCounter <= txCounter + 1;
            end
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
            end else begin
                txCounter <= txCounter + 1;
            end
        end
        TX_STATE_DEBOUNCE: begin
            if (txCounter == 25'b11111111111111111111) begin
                if (btn1 == 1)
                    txState <= TX_STATE_IDLE;
            end else begin
                txCounter <= txCounter + 1;
            end
        end
    endcase
end

endmodule
