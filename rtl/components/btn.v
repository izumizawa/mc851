module btn #(
    parameter ADDR_WIDTH = 8
) (
    input clk,
    input btn1,
    input btn2,
    input read_enable,
    input [ADDR_WIDTH-1:0] address,
    output reg [31:0] data_out
);

    reg btn1_buffer;
    reg btn2_buffer;

    always @(posedge clk) begin
        if (!btn1)
            btn1_buffer <= ~btn1;
        
        if (!btn2) 
            btn2_buffer <= ~btn2;

        if (read_enable) begin
            case (address)
                0: begin
                    data_out <= btn1_buffer;
                    btn1_buffer <= 0; // reset bt1_buffer after reading, runs in the next clock cycle
                end
                1: begin
                    data_out <= btn2_buffer;
                    btn2_buffer <= 0; // reset bt2_buffer after reading, runs in the next clock cycle
                end
                default: data_out <= 0;
            endcase
        end else begin
            data_out <= 0;
        end
    end
endmodule
