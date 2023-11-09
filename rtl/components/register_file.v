module register_file (
    input clk,
    input wire [4:0] read_reg1, // Registrador a ser lido
    input wire [4:0] read_reg2, // Outro registrador a ser lido
    input wire [4:0] write_reg, // O regitrador no qual os dados serão escritos
    input wire write_enable,
    input wire [31:0] write_data, // O dado que será escrito

    output wire [31:0] read_data1, // Dado que foi lido
    output wire [31:0] read_data2, // Outro dado que foi lido
    output reg [31:0] uart_data
);
    reg [31:0] registers [0:31];

    // Lógica de leitura
    assign read_data1 = (read_reg1 != 0) ? registers[read_reg1] : 0;
    assign read_data2 = (read_reg2 != 0) ? registers[read_reg2] : 0;

    // Lógica de escrita
    integer i;
    always @(posedge clk) begin
        if (write_enable) begin
            if (write_reg != 0) begin
                for(i=0; i<31; i=i+1) begin
                    if (i == write_reg) begin
                        registers[i] <= write_data;
                    end
                end
            end
        end
    end

    assign uart_data = registers[5];
endmodule
