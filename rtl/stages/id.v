// Instruction decode stage.
// modules = ["Register File", "Control Unit"]

module RegisterFile (
    input wire clock,          // Sinal de clock
    input wire reset,        // Sinal de reset assíncrono ativo baixo
    input wire [4:0] read_reg1, // Registrador a ser lido
    input wire [4:0] read_reg2, // Outro registrador a ser lido
    input wire [4:0] write_reg, // O regitrador no qual os dados serão escritos
    input wire write_enable,
    input wire [31:0] write_data, // O dado que será escrito
    output wire [31:0] read_data1, // Dado que foi lido
    output wire [31:0] read_data2 // Outro dado que foi lido
);

    reg [31:0] registers [31:0];

    // Lógica de leitura
    assign read_data1 = (read_reg1 != 5'b0) ? registers[read_reg1] : 32'b0;
    assign read_data2 = (read_reg2 != 5'b0) ? registers[read_reg2] : 32'b0;

    // Lógica de escrita
    always @(posedge clock or negedge reset) begin
        if (!reset) begin
            registers[0] <= 32'b0;
        end else if (write_enable) begin
            registers[write_reg] <= write_data;
        end
    end
endmodule

module Decoder (
    input wire [31:0] instruction, 
);
    reg [6:0] opcode;
    reg [4:0] rd;
    reg [2:0] funct3;
    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [6:0] funct7;

    // Read registers
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];

    // Write register
    assign rd = instruction[11:7];

    // Instruction decode
    assign opcode = instruction[6:0];
    assign funct7 = instruction[31:25];
    assign funct3 = instruction[14:12];

    always @(*) begin 
        case (opcode) 
            
    end

endmodule
