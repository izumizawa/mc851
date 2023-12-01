
module soc #(
    parameter ROMFILE="counter_led.hex"
) (
    input clk,
    input btn1,
    input btn2,
    output [5:0] led,
    output uart_tx
);

    cpu #(
        .ROM_ADDR_WIDTH(ROM_ADDR_WIDTH),
        .RAM_ADDR_WIDTH(RAM_ADDR_WIDTH),
        .BTN_ADDR_WIDTH(BTN_ADDR_WIDTH)
    ) cpu_inst (
        .clk (clk),
        .reset_n (btn2),
        .rom_read_enable(rom_read_enable),
        .rom_address(rom_address),
        .rom_data_out(rom_data_out),
        .ram_write_enable(ram_write_enable),
        .ram_data_in(ram_data_in),
        .ram_read_enable(ram_read_enable),
        .ram_address(ram_address),
        .ram_data_out(ram_data_out),
        .btn_read_enable(btn_read_enable),
        .btn_address(btn_address),
        .btn_data_out(btn_data_out),
        .led_address(led_address),
        .led_write_enable(led_write_enable),
        .led_data_in(led_data_in),
        .uart_data(data)
    );

    localparam ROM_ADDR_WIDTH = 8;
    wire  [ROM_ADDR_WIDTH-1:0]  rom_address;
    wire  rom_read_enable;
    wire  [31:0]  rom_data_out;

    rom #(
        .ADDR_WIDTH(ROM_ADDR_WIDTH),
        .ROMFILE(ROMFILE)
    ) rom_inst (
        .clk            (clk            ),
        .read_enable    (rom_read_enable),
        .address        (rom_address    ),
        .data_out       (rom_data_out   )
    );

    localparam RAM_ADDR_WIDTH = 8;
    wire ram_write_enable;
    wire ram_read_enable;
    wire [RAM_ADDR_WIDTH-1:0] ram_address;
    wire [31:0] ram_data_in;
    wire [31:0] ram_data_out;

    ram #( .ADDR_WIDTH(RAM_ADDR_WIDTH) ) ram_inst (
        .clk            (clk                ),
        .write_enable   (ram_write_enable   ),
        .read_enable    (ram_read_enable    ),
        .address        (ram_address        ),
        .data_in        (ram_data_in        ),
        .data_out       (ram_data_out       )
    );

    localparam BTN_ADDR_WIDTH = 8;
    wire btn_read_enable;
    wire  [BTN_ADDR_WIDTH-1:0] btn_address;
    wire [31:0] btn_data_out;

    btn #( .ADDR_WIDTH(BTN_ADDR_WIDTH) ) btn_inst (
        .clk            (clk                ),
        .btn1           (btn1               ),
        .btn2           (btn2               ),
        .read_enable    (btn_read_enable    ),
        .address        (btn_address        ),
        .data_out       (btn_data_out       )
    );
    
    localparam LED_ADDR_WIDTH = 8;
    wire led_write_enable;
    wire  [LED_ADDR_WIDTH-1:0] led_address;
    wire [31:0] led_data_in;

    led #( .ADDR_WIDTH(LED_ADDR_WIDTH) ) led_inst (
        .clk            (clk                ),
        .write_enable   (led_write_enable   ),
        .address        (led_address        ),
        .data_in        (led_data_in        ),
        .led            (led                )
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

localparam DELAY_FRAMES = 234;

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