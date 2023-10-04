// Top model. Describes the whole CPU and its components.
`include "define.v"
`include "../components/register_file.v"
`include "../components/alu_module.v"

module cpu (
    input         clk,
    input         reset_n,
    input         mmu_mem_ready,
    input [31:0]  mmu_data_out,
    output        mmu_write_enable,
    output        mmu_read_enable,
    output        mmu_mem_signed_read,
    output [ 1:0] mmu_mem_data_width,
    output [31:0] mmu_address,
    output [31:0] mmu_data_in
);
    // IF/ID Register
    reg [31:0] ifid_pc;
    reg [31:0] ifid_ir;

    // ID/EX Register
    reg [31:0] idex_pc;
    reg idex_reset;
    reg [2:0] idex_branch_op;
    reg idex_reg_write;
    reg idex_mem_read;
    reg idex_mem_write;
    reg idex_mem_to_reg;
    reg idex_alu_src;
    reg [ 3:0] idex_alu_op;
    reg [31:0] idex_data_read_1;
    reg [31:0] idex_data_read_2;
    reg [ 4:0] idex_rs1;
	reg [ 4:0] idex_rs2;
	reg [ 4:0] idex_rd;
	reg [31:0] idex_imm;

    // EX/MEM Register
    reg exmem_reset;
    reg [2:0] exmem_branch_op;
    reg exmem_mem_to_reg;
    reg exmem_reg_write;
    reg exmem_mem_read;
    reg exmem_mem_write;
    reg [31:0] exmem_branch_target;
    //TODO: Substituir pelos nomes explícitos das flags conforme necessário (ex.: zero, negative, overflow, carry)
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


    /***************************************************************************
     * Instruction Fetch (IF) stage
     **************************************************************************/
    reg [31:0] pc;
    reg if_stall;

    // TODO: Memory Access Control e Hazard Unit

    assign mmu_write_enable = 0;
    assign mmu_read_enable = 1;
    assign mmu_mem_signed_read = 0;
    assign mmu_mem_data_width = `MMU_WIDTH_WORD;

    assign mmu_address = pc;
    assign mmu_data_in = 0; // TODO: serve apenas para leitura. Deve ser retirado/modificado para que CPU possa escrever na memória

    always @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            pc <= 0;
            ifid_pc <= 32'b0;
            ifid_ir <= `RISCV_NOP;
        end else begin
            idex_reset <= 0;
            exmem_reset <= 0;
            ifid_pc <= pc;

            case (exmem_branch_op)
                `NOT_BRANCH: begin
                    if(mmu_mem_ready) begin
                        pc <= pc + 4;
                        ifid_ir <= mmu_data_out;
                    end else begin
                        ifid_ir <= `RISCV_NOP;
                    end
                end
                `BRANCH_BEQ: begin
                    if (exmem_alu_out == 32'b0) begin
                        pc <= exmem_branch_target;
                        idex_reset <= 1;
                        exmem_reset <= 1;
                    end else begin
                        pc <= pc + 4;
                    end
                end
            endcase
        end
    end
    // -------------------------------------------------------------------------


    /***************************************************************************
     * Instruction Decode (ID) stage
     **************************************************************************/
    wire [6:0] id_opcode;
    wire [2:0] id_funct3;
    wire [6:0] id_funct7;
    wire [31:0] id_i_imm;
    wire [12:0] id_b_imm;
    wire [31:0] id_s_imm;
    wire [31:0] id_shamt;

    wire [31:0] read_data_1;
    wire [31:0] read_data_2;

    register_file regfile(
        .clk(clk),
        .read_reg1(idex_rs1),
        .read_reg2(idex_rs2),
        .write_reg(memwb_rd),
        .write_enable(memwb_reg_write),
        .write_data(wb_data),
        .read_data1(read_data_1),
        .read_data2(read_data_2)
    );

    // Assigns
    assign id_opcode = ifid_ir[6:0];
    assign id_funct7 = ifid_ir[31:25];
    assign id_funct3 = ifid_ir[14:12];

    // Default i_imm
    assign id_i_imm = { { 20{ ifid_ir[31] } }, ifid_ir[31:20] };
    assign id_shamt = { 27'b0, ifid_ir[24:20] };
    // B-type b_imm
    assign id_b_imm = { ifid_ir[31], ifid_ir[7], ifid_ir[30:25], ifid_ir[11:8], 1'b0 };
    assign id_s_imm = { { 20 {ifid_ir[31] } }, ifid_ir[31:25], ifid_ir[11:7] };

    always @(posedge clk, negedge reset_n) begin
        if (!reset_n || idex_reset) begin
            // Reset ID/EX registers
            idex_branch_op <= `NOT_BRANCH;
            idex_mem_read <= 0;
            idex_mem_write <= 0;
            idex_mem_to_reg <= 0;
            idex_alu_src <= 0;
            idex_alu_op <= 4'b0;
            idex_data_read_1 <= 32'b0;
            idex_data_read_2 <= 32'b0;
            idex_rs1 <= 5'b0;
            idex_rs2 <= 5'b0;
            idex_rd <= 5'b0;
            idex_imm <= 32'b0;
            idex_reg_write <= 0;
            idex_pc <= 0;
        end else begin

        idex_pc <= ifid_pc;
        idex_rs1 <= ifid_ir[19:15];
        idex_rs2 <= ifid_ir[24:20];
        idex_rd <= ifid_ir[11:7];
        idex_imm <= { { 20 { id_i_imm[11] } }, id_i_imm[11:0] };
        idex_mem_to_reg <= 0;
        idex_reg_write <= 0;
        idex_mem_read <= 0;
        idex_mem_write <= 0;
        idex_branch_op <= `NOT_BRANCH;
        idex_data_read_1 <= read_data_1;
        idex_data_read_2 <= read_data_2;

        case (id_opcode)
            // R-type instructions
            7'b0110011: begin
                idex_reg_write <=  1; // True
                idex_alu_src <= `ALU_SRC_FROM_REG;
                if (id_funct3 == 3'b000) begin
                    if (id_funct7 == 7'b0000000) begin
                        idex_alu_op <= `ALU_ADD;
                    end else begin
                        idex_alu_op <= `ALU_SUB;
                    end
                end else if (id_funct3 == 3'b001) begin
                    idex_alu_op <= `ALU_SLL;
                end else if (id_funct3 == 3'b010) begin
                    idex_alu_op <= `ALU_SLT;
                end else if (id_funct3 == 3'b011) begin
                    idex_alu_op <= `ALU_SLTU;
                end else if (id_funct3 == 3'b100) begin
                    idex_alu_op <= `ALU_XOR;
                end else if (id_funct3 == 3'b101) begin
                    if (id_funct7 == 7'b0000000) begin
                        idex_alu_op <= `ALU_SRL;
                    end else begin
                        idex_alu_op <= `ALU_SRA;
                    end
                end else if (id_funct3 == 3'b110) begin
                    idex_alu_op <= `ALU_OR;
                end else if (id_funct3 == 3'b111) begin
                    idex_alu_op <= `ALU_AND;
                end
            end

            // I-type instructions
            7'b0010011: begin
                idex_reg_write <=  1; // True
                idex_alu_src <= `ALU_SRC_FROM_IMM;
                idex_imm <= id_i_imm;
                if (id_funct3 == 3'b000) begin
                    idex_alu_op <= `ALU_ADD;
                end else if (id_funct3 == 3'b010) begin
                    idex_alu_op <= `ALU_ADD;
                end else if (id_funct3 == 3'b011) begin
                    idex_alu_op <= `ALU_SLT;
                end else if (id_funct3 == 3'b100) begin
                    idex_alu_op <= `ALU_XOR;
                end else if (id_funct3 == 3'b110) begin
                    idex_alu_op <= `ALU_OR;
                end else if (id_funct3 == 3'b111) begin
                    idex_alu_op <= `ALU_AND;
                end else if (id_funct3 == 3'b001) begin
                    idex_imm <= id_shamt;
                    idex_alu_op <= `ALU_SLL; //slli
                end else if (id_funct3 == 3'b101) begin
                    idex_imm <= id_shamt;
                    if (id_funct7 == 7'b0000000) begin
                        idex_alu_op <= `ALU_SRL; //srli
                    end else begin
                        idex_alu_op <= `ALU_SRA; //srai
                    end
                end
            end

            // S-type instructions
            7'b0100011: begin
                idex_mem_write <= 1; // True
                idex_alu_src <= `ALU_SRC_FROM_IMM;
                idex_alu_op <= `ALU_ADD;
                idex_imm <= id_s_imm;
            end

            // B-type instructions
            7'b1100011: begin
                idex_imm <= { { 20 { id_b_imm[12] } }, id_b_imm[11:0] };

                idex_alu_src <= `ALU_SRC_FROM_REG;

                if (id_funct3 == `BRANCH_BEQ) begin // BEQ
                    idex_alu_op <= `ALU_SUB;
                    idex_branch_op <= `BRANCH_BEQ;

                end else if (id_funct3 == 3'b101) begin //BGE
                // TODO: BGE
                end else if (id_funct3 == 3'b111) begin //BGEU
                // TODO: BGEU
                end else if (id_funct3 == 3'b100) begin //BLT
                // TODO: BLT
                end else if (id_funct3 == 3'b110) begin //BLTU
                // TODO: BLTU
                end else if (id_funct3 == 3'b001) begin //BNE
                // TODO: BNE
                end
            end
        endcase
    end
    end
    // -------------------------------------------------------------------------


    /***************************************************************************
     * Execute (EX) stage
     **************************************************************************/
    wire [31:0] alu_input_a;
    wire [31:0] alu_input_b;
    wire [31:0] alu_out;

    // Modules instantiations
    alu_module alu_inst(
        .alu_input_op(idex_alu_op),
        .alu_input_a(alu_input_a),
        .alu_input_b(alu_input_b),
        .alu_output_result(alu_out) // Wire always required in modules output
    );

    // TODO: Forwarding Unit.

    assign alu_input_a = idex_data_read_1;
    assign alu_input_b = (idex_alu_src == `ALU_SRC_FROM_REG) ? idex_data_read_2 : idex_imm;

    always @(posedge clk, negedge reset_n) begin
        if (!reset_n || exmem_reset) begin
            // Reset EX/MEM registers
            exmem_branch_op <= `NOT_BRANCH;
            exmem_mem_to_reg <= 0;
            exmem_reg_write <= 0;
            exmem_mem_read <= 0;
            exmem_mem_write <= 0;
            exmem_flags <= 4'b0;
            exmem_data_read_2 <= 32'b0;
            exmem_rd <= 5'b0;
            exmem_alu_out <= 0;
            exmem_branch_target <= 0;
        end else begin
            exmem_branch_op <= idex_branch_op;
            exmem_branch_target <= idex_pc + idex_imm;
            exmem_mem_read <= idex_mem_read;
            exmem_mem_to_reg <= idex_mem_to_reg;
            exmem_mem_write <= idex_mem_write;
            exmem_rd <= idex_rd;
            exmem_reg_write <= idex_reg_write;

            exmem_alu_out <= alu_out;
        end
    end
    // -------------------------------------------------------------------------


    /***************************************************************************
     * Memory access (MEM) stage
     **************************************************************************/
    always @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            // Reset MEM/WB registers
            memwb_mem_data_read <= 32'b0;
            memwb_alu_out <= 32'b0;
            memwb_rd <= 5'b0;
            memwb_reg_write <= 0;
            memwb_mem_to_reg <= 0;
        end else begin
            memwb_alu_out <= exmem_alu_out;
            memwb_rd <= exmem_rd;
            memwb_reg_write <= exmem_reg_write;
            memwb_mem_to_reg <= exmem_mem_to_reg;
        end
    end
    // -------------------------------------------------------------------------


    /***************************************************************************
     * Writeback (WB) stage
     **************************************************************************/
    always @(*) begin
        if(memwb_mem_to_reg) begin
            wb_data = memwb_mem_data_read;
        end else begin
            wb_data = memwb_alu_out;
        end
    end
    // -------------------------------------------------------------------------

endmodule
