`include "../define.v"

module btn_tb();
    reg clk;
    reg btn1;
    reg btn2;
    reg read_enable;
    reg [BTN_ADDR_WIDTH-1:0] address;
    wire [31:0] data_out;

    localparam BTN_ADDR_WIDTH = 8;
    reg [31:0] result_data_out_1;
    reg [31:0] result_data_out_2;

    initial begin
        $dumpfile("btn_wave.vcd");
        $dumpvars;
        clk = 0;
        forever #1 clk = ~clk;
    end

    
    btn #( .ADDR_WIDTH(BTN_ADDR_WIDTH) ) btn_inst (
        .clk            (clk                ),
        .btn1           (btn1               ),
        .btn2           (btn2               ),
        .read_enable    (read_enable    ),
        .address        (address        ),
        .data_out       (data_out       )
    );

    task test_btn();
    begin
        $write("  test_btn: ");

        btn1 = 1;
        #1
        btn1 = 0;
        
        #2
        read_enable = 1;
        address = 0;
        
        #2
        result_data_out_1 = data_out;
        read_enable = 0;
        
        #2
        read_enable = 1;
        address = 0;

        #2
        result_data_out_2 = data_out;
        read_enable = 0;

        #2
        if (result_data_out_1 != 1 || result_data_out_2 != 0)
            $display("result_data_out_1 should be 0x1 and result_data_out_2 should be 0x0, but is %h and %h", result_data_out_1, result_data_out_2);
        else
            $display("ok!");
    end
    endtask

    initial begin
        $display("btn_tb: starting tests");

        test_btn();

        $dumpoff;
        $finish;
    end

endmodule
