// Top model. Describes the whole CPU and its components.
`include "define.v"

module cpu (
    input clk, reset
);
    // IF/ID Register
    reg [31:0] ifid_pc;
    reg [31:0] ifid_ir;

    // ID/EX Register
    reg [31:0] idex_pc;
    // ... sinais de controle
    reg idex_reg_write;
    reg idex_branch;
    reg idex_mem_read;
    reg idex_mem_write;
    reg idex_mem_to_reg;
    reg idex_alu_src;
    reg [ 3:0] idex_alu_op; 
    // TODO: Ajustar conforme implementação da ALU e Pipeline
    reg [31:0] idex_data_read_1;
    reg [31:0] idex_data_read_2;
    reg [ 4:0] idex_rs1;
	reg [ 4:0] idex_rs2;
	reg [ 4:0] idex_rd;
	reg [12:0] idex_imm;

    // EX/MEM Register
    reg exmem_mem_to_reg;
    reg exmem_reg_write;
    reg exmem_branch;
    reg exmem_mem_read;
    reg exmem_mem_write;
    reg [31:0] exmem_branch_target;
    /* //TODO: Substituir isso aqui pelos nomes explícitos das flags conforme
     * //TODO: for necessário (ex.: zero, negative, overflow, carry) */
    reg [ 3:0] exmem_flags;
    reg [31:0] exmem_alu_out;
    reg [31:0] exmem_data_read_2;
    reg [ 4:0] exmem_rd;

    // MEM/WB Register
    reg [31:0] memwb_mem_data_read;
    reg [31:0] memwb_alu_out;
    reg [ 4:0] memwb_rd;
    reg memwb_reg_write;
    reg memwb_mem_to_reg;

    reg [31:0] wb_data; // conectado do mux do WB para escrita no banco de registradores

    // Control Unit e Hazard Unit
    reg pc_write;
    reg ifid_write;
    // TODO: Gerar sinais de controle ID/EX a partir da instrução decodificada

    // Forwarding Unit
    // TODO: A fazer.


    /***************************************************************************
     * Instruction Fetch (IF) stage
     **************************************************************************/
    reg [31:0] pc;

    always @(posedge clk) begin
        ;
    end
    // -------------------------------------------------------------------------


    /***************************************************************************
     * Instruction Decode (ID) stage
     **************************************************************************/

    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;
    reg [12:0] imm;

    wire [31:0] read_data_1;
    wire [31:0] read_data_2;

    register_file regfile(
        .clk(clk),
        .read_reg1(idex_rs1),
        .read_reg2(idex_rs2),
        .write_reg(idex_rd),
        .write_enable(memwb_reg_write),
        .write_data(wb_data),
        .read_data1(read_data_1),
        .read_data2(read_data_2)
    );
       
    always @(posedge clk) begin
        // R-type
        opcode = ifid_ir[6:0];
        funct7 = ifid_ir[31:25];
        funct3 = ifid_ir[14:12];
        // I-type
        imm = ifid_ir[31:20];


        idex_rs1 <= ifid_ir[19:15];
        idex_rs2 <= ifid_ir[24:20];
        idex_rd <= ifid_ir[11:7];
        idex_imm <= { { 20 { imm[11] } }, imm[11:0] };
        
        idex_mem_to_reg <= 0;
        idex_reg_write <= 0;
        idex_branch <= 0;
        idex_mem_read <= 0;
        idex_mem_write <= 0;

        idex_data_read_1 <= read_data_1;
        idex_data_read_2 <= read_data_2;

        case (opcode) 
            // R-type instructions
            7'b0110011: begin 
                idex_reg_write <=  1; // True
                idex_alu_src <= `ALU_SRC_FROM_REG;
                if (funct3 == 3'b000) begin 
                    if (funct7 == 7'b0000000) begin 
                        idex_alu_op <= `ALU_ADD;
                    end else begin 
                        idex_alu_op <= `ALU_SUB;
                    end 
                end else if (funct3 == 3'b001) begin
                    idex_alu_op <= `ALU_SLL; 
                end else if (funct3 == 3'b010) begin 
                    idex_alu_op <= `ALU_SLT;
                end else if (funct3 == 3'b011) begin
                    idex_alu_op <= `ALU_SLTU;
                end else if (funct3 == 3'b100) begin 
                    idex_alu_op <= `ALU_XOR;
                end else if (funct3 == 3'b101) begin
                    if (funct7 == 7'b0000000) begin
                        idex_alu_op <= `ALU_SRL;
                    end else begin 
                        idex_alu_op <= `ALU_SRA;
                    end 
                end else if (funct3 == 3'b110) begin
                    idex_alu_op <= `ALU_OR;
                end else if (funct3 == 3'b111) begin 
                    idex_alu_op <= `ALU_AND;
                end
            end

            // R-type instructions
            7'b0010011: begin
                idex_reg_write <=  1; // True
                idex_alu_src <= `ALU_SRC_FROM_IMM;
                if (funct3 == 0) begin
                    idex_alu_op <= `ALU_ADD;
                end
            end
        endcase
    end
    // -------------------------------------------------------------------------


    /***************************************************************************
     * Execute (EX) stage
     **************************************************************************/
    reg [31:0] alu_input_a;
    reg [31:0] alu_input_b;
    
    wire [31:0] alu_out;

    // Modules instantiations
    alu_module alu(
        .alu_input_op(idex_alu_op),
        .alu_input_a(alu_input_a),
        .alu_input_b(alu_input_b),
        .alu_output_result(alu_out) // Wire always required in modules output
    );

    always @(posedge clk) begin
        exmem_branch <= idex_branch;
        exmem_mem_read <= idex_mem_read;
        exmem_mem_to_reg <= idex_mem_to_reg;
        exmem_mem_write <= idex_mem_write;
        exmem_rd <= idex_rd;
        exmem_reg_write <= idex_reg_write;

        alu_input_a <= idex_data_read_1;
        case(idex_alu_src)
            `ALU_SRC_FROM_REG: begin
                alu_input_b <= idex_data_read_2;
            end
            `ALU_SRC_FROM_IMM: begin
                alu_input_b <= idex_imm;
            end
        endcase

        exmem_alu_out <= alu_out;
    end
    // -------------------------------------------------------------------------


    /***************************************************************************
     * Memory access (MEM) stage
     **************************************************************************/
    always @(posedge clk) begin
        memwb_alu_out <= exmem_alu_out;
        memwb_rd <= exmem_rd;
        memwb_reg_write <= exmem_reg_write;
        memwb_mem_to_reg <= exmem_mem_to_reg;
    end
    // -------------------------------------------------------------------------


    /***************************************************************************
     * Writeback (WB) stage
     **************************************************************************/
    always @(posedge clk) begin
        if(memwb_mem_to_reg) begin
            wb_data <= memwb_mem_data_read;
        end else begin
            wb_data <= memwb_alu_out;
        end
    end
    // -------------------------------------------------------------------------

endmodule
