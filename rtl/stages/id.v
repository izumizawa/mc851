// Instruction decode stage.
// modules = ["Register File", "Control Unit"]
`include "define.v"

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
            if (write_reg != 5'b00000) begin
                registers[write_reg] <= write_data;
            end
        end
    end
endmodule


module Decoder (
    input wire [31:0] instruction,
    output reg [4:0] read_reg1,
    output reg [4:0] read_reg2,
    output reg [4:0] write_reg,
    output reg [3:0] alu_input_op;
);
    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;
    
    // Read registers
    assign read_reg1 <= instruction[19:15];
    assign read_reg2 <= instruction[24:20];

    // Write register
    assign write_reg <= instruction[11:7];

    // Instruction decode
    assign opcode <= instruction[6:0];
    assign funct7 <= instruction[31:25];
    assign funct3 <= instruction[14:12];

    always @(*) begin 
        case (opcode) 
            // R-type instructions
            7'b0110011: begin 
                write_enable <= 1;
                alu_input_enable <= 1;

                if (funct3 == 3'b000) begin 
                    if (funct7 == 7'b0000000) begin 
                        alu_input_op <= `ALU_ADD;
                    end else begin 
                        alu_input_op <= `ALU_SUB;
                    end 
                end else if (funct3 == 3'b001) begin
                    alu_input_op <= `ALU_SLL; 
                end else if (funct3 == 3'b010) begin 
                    alu_input_op <= `ALU_SLT;
                end else if (funct3 == 3'b011) begin
                    alu_input_op <= `ALU_SLTU;
                end else if (funct3 == 3'b100) begin 
                    alu_input_op <= `ALU_XOR;
                end else if (funct3 == 3'b101) begin
                    if (funct7 == 7'b0000000) begin
                        alu_input_op <= `ALU_SRL;
                    end else begin 
                        alu_input_op <= `ALU_SRA;
                    end 
                end else if (funct3 == 3'b110) begin
                    alu_input_op <= `ALU_OR;
                end else if (funct3 == 3'b111) begin 
                    alu_input_op <= `ALU_AND;
                end
            end
        endcase
    end
endmodule
