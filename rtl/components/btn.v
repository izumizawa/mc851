module btn #(
    parameter ADDR_WIDTH = 8
) (
    input clk,
    input btn1,
    input btn2,
    input read_enable,
    input [ADDR_WIDTH-1:0] address,
    output wire [31:0] data_out
);

    reg btn1_buffer;
    reg btn2_buffer;

    assign data_out = (read_enable) ? (btn1_buffer | btn2_buffer) : 0;

    always @(posedge clk) begin
        if (!btn1)
            btn1_buffer <= ~btn1;
        
        if (!btn2) 
            btn2_buffer <= ~btn2;

        if (read_enable) begin
            case (address)
                0: begin
                    btn1_buffer <= 0; // reset bt1_buffer after reading, runs in the next clock cycle
                end
                1: begin
                    btn2_buffer <= 0; // reset bt2_buffer after reading, runs in the next clock cycle
                end
            endcase
        end
    end
endmodule
