module uart (
    input clk,
    input write_enable,
    input read_enable,
    input [31:0] data_in, // O dado que será escrito
    input address[31:0] address,
    input uart_rx, // write on uart
    output uart_tx // transmit from uart
    output reg [31:0] data_out
);

    // Baud rate/frequency
    localparam DELAY_FRAMES = 234; // 27,000,000 (27Mhz) / 115200 Baud rate
    localparam HALF_DELAY_WAIT = (DELAY_FRAMES / 2);

    // RX state machine
    localparam RX_STATE_IDLE = 0;
    localparam RX_STATE_START_BIT = 1;
    localparam RX_STATE_READ_WAIT = 2;
    localparam RX_STATE_READ = 3;
    localparam RX_STATE_STOP_BIT = 5;

    // Device storage
    reg [31:0] data;

    // RX registers
    reg [3:0] rxState = 0;
    reg [12:0] rxCounter = 0;
    reg [2:0] rxBitNumber = 0;
    reg [7:0] dataIn = 0;
    reg byteReady = 0;
    reg rxByteCounter = 0;

    always @(posedge clk) begin
        case (rxState)
            RX_STATE_IDLE: begin
                if (uart_rx == 0) begin
                    rxState <= RX_STATE_START_BIT;
                    rxCounter <= 1;
                    rxBitNumber <= 0;
                    byteReady <= 0;
                end
            end
            RX_STATE_START_BIT: begin
                if (rxCounter == HALF_DELAY_WAIT) begin
                    rxState <= RX_STATE_READ_WAIT;
                    rxCounter <= 1;
                end else
                    rxCounter <= rxCounter + 1;
            end
            RX_STATE_READ_WAIT: begin
                rxCounter <= rxCounter + 1;
                if ((rxCounter + 1) == DELAY_FRAMES) begin
                    rxState <= RX_STATE_READ;
                end
            end
            RX_STATE_READ: begin
                rxCounter <= 1;
                dataIn <= {uart_rx, dataIn[7:1]};
                rxBitNumber <= rxBitNumber + 1;
                if (rxBitNumber == 3'b111) begin
                    rxState <= RX_STATE_STOP_BIT;
                    byteCounter <= byteCounter + 1;
                    if (byteCounter == 0)
                        data[31:24] <= dataIn;
                    else if (byteCounter == 1)
                        data[23:16] <= dataIn;
                    else if (byteCounter == 2)
                        data[15:8] <= dataIn;
                    else if (byteCounter == 3)
                        data[7:0] <= dataIn;
                        byteCounter <= 0;
                end else begin
                    rxState <= RX_STATE_READ_WAIT;
                end
            end
            RX_STATE_STOP_BIT: begin
                rxCounter <= rxCounter + 1;
                if ((rxCounter + 1) == DELAY_FRAMES) begin
                    rxState <= RX_STATE_IDLE;
                    rxCounter <= 0;
                    byteReady <= 1;
                end
            end
        endcase

        if (write_enable) begin
            data <= write_data;
        end if(read_enable) else begin
            data_out <= data;
        end else begin
            data_out <= 0;
        end
    end
endmodule
