`include "define.v"

module cpu (
    input wire          clk,
    input wire          reset_n,
    input wire          mmu_mem_ready,
    input wire [31:0]   mmu_data_out,
    output reg          mmu_write_enable,
    output reg          mmu_read_enable,
    output reg          mmu_mem_signed_read,
    output reg [ 1:0]   mmu_mem_data_width,
    output reg [31:0]   mmu_address,
    output reg [31:0]   mmu_data_in
);
    // PC (Program Counter)
    reg [31:0] pc;
    wire pc_stall;

    // IF/ID Register
    wire ifid_flush;
    wire ifid_stall;
    reg [31:0] ifid_pc;
    reg [31:0] ifid_ir;

    // ID/EX Register
    wire idex_flush;
    wire idex_stall;
    reg [31:0] idex_pc;
    reg [2:0] idex_branch_op;
    reg idex_reg_write;
    reg idex_mem_read;
    reg idex_mem_write;
    reg [ 1:0] idex_mem_data_width;
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
    wire exmem_flush;
    wire exmem_stall;
    reg exmem_mem_to_reg;
    reg exmem_reg_write;
    reg exmem_mem_read;
    reg exmem_mem_write;
    reg [ 1:0] exmem_mem_data_width;
    reg [31:0] exmem_branch_target;
    reg exmem_branch_taken;
    reg [31:0] exmem_alu_out;
    reg [31:0] exmem_data_read_2;
    reg [ 4:0] exmem_rd;

    // MEM/WB Register
    wire memwb_flush;
    reg [31:0] memwb_mem_data_read;
    reg [31:0] memwb_alu_out;
    reg [ 4:0] memwb_rd;
    reg memwb_reg_write;
    reg memwb_mem_to_reg;

    // Writeback
    wire [31:0] wb_data;


    /***************************************************************************
     * L1 Instruction Cache
     */
    reg l1i_mmu_mem_ready;
    wire [31:0] l1i_mmu_data_out;
    wire [31:0] l1i_mmu_address;
    wire l1i_cache_miss;
    wire [31:0] l1i_data_out;

    l1_instruction_cache l1i_inst (
        .clk(clk),
        .reset_n(reset_n),
        .address(pc),
        .mmu_mem_ready(l1i_mmu_mem_ready),
        .mmu_data_out(l1i_mmu_data_out),
        .mmu_address(l1i_mmu_address),
        .cache_miss(l1i_cache_miss),
        .data_out(l1i_data_out)
    );
    // -------------------------------------------------------------------------


    /***************************************************************************
     * L1 Data Cache
     */
    reg l1d_mmu_mem_ready;
    wire [31:0] l1d_mmu_data_out;
    wire l1d_mmu_write_enable;
    wire l1d_mmu_read_enable;
    wire l1d_mmu_mem_signed_read;
    wire [ 1:0] l1d_mmu_mem_data_width;
    wire [31:0] l1d_mmu_data_in;
    wire [31:0] l1d_mmu_address;
    wire l1d_cache_miss;
    wire [31:0] l1d_data_out;

    l1_data_cache l1d_inst (
        .clk(clk),
        .reset_n(reset_n),
        .mem_write(exmem_mem_write),
        .mem_read(exmem_mem_read),
        .address(exmem_alu_out),
        .data_in(exmem_data_read_2),
        .mmu_mem_ready(l1d_mmu_mem_ready),
        .mmu_data_out(l1d_mmu_data_out),
        .mmu_write_enable(l1d_mmu_write_enable),
        .mmu_read_enable(l1d_mmu_read_enable),
        .mmu_mem_signed_read(l1d_mmu_mem_signed_read),
        .mmu_mem_data_width(l1d_mmu_mem_data_width),
        .mmu_data_in(l1d_mmu_data_in),
        .mmu_address(l1d_mmu_address),
        .cache_miss(l1d_cache_miss),
        .data_out(l1d_data_out)
    );
    // -------------------------------------------------------------------------


    // Memory Acess Control
    assign l1d_mmu_data_out = mmu_data_out;
    assign l1i_mmu_data_out = mmu_data_out;

    always @(*) begin
        l1d_mmu_mem_ready = 0;
        l1i_mmu_mem_ready = 0;

        if (l1d_cache_miss) begin
            mmu_write_enable = l1d_mmu_write_enable;
            mmu_read_enable = l1d_mmu_read_enable;
            mmu_mem_signed_read = l1d_mmu_mem_signed_read;
            mmu_mem_data_width = l1d_mmu_mem_data_width;
            mmu_address = l1d_mmu_address;
            mmu_data_in = l1d_mmu_data_in;

            l1d_mmu_mem_ready = mmu_mem_ready;
        end else if (l1i_cache_miss) begin
            mmu_write_enable = 0;
            mmu_read_enable = 1;
            mmu_mem_signed_read = 0;
            mmu_mem_data_width = `MMU_WIDTH_WORD;
            mmu_address = l1i_mmu_address;
            mmu_data_in = 0;

            l1i_mmu_mem_ready = mmu_mem_ready;
        end else begin
            mmu_write_enable = 0;
            mmu_read_enable = 0;
            mmu_mem_signed_read = 0;
            mmu_mem_data_width = `MMU_WIDTH_WORD;
            mmu_address = 0;
            mmu_data_in = 0;
        end
    end


    // Flush
    assign ifid_flush = (pc_stall && !idex_stall) || exmem_branch_taken;
    assign idex_flush = exmem_branch_taken;
    assign exmem_flush = exmem_branch_taken;
    assign memwb_flush = exmem_stall;

    // Stall
    assign pc_stall = ifid_stall || l1i_cache_miss;
    assign ifid_stall = idex_stall;
    assign idex_stall = exmem_stall;
    assign exmem_stall = l1d_cache_miss;


    /***************************************************************************
     * Instruction Fetch (IF) stage
     **************************************************************************/

    always @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            pc <= 0;
        end else if (exmem_branch_taken) begin
            pc <= exmem_branch_target;
        end else if (!pc_stall) begin
            pc <= pc + 4;
        end
    end

    always @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            ifid_pc <= 32'b0;
            ifid_ir <= `RISCV_NOP;
        end else if(!ifid_stall) begin
            ifid_pc <= pc;
            ifid_ir <= l1i_data_out;
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
    wire [ 4:0] id_rs1;
	wire [ 4:0] id_rs2;

    wire [31:0] read_data_1;
    wire [31:0] read_data_2;

    register_file regfile(
        .clk(clk),
        .read_reg1(id_rs1),
        .read_reg2(id_rs2),
        .write_reg(memwb_rd),
        .write_enable(memwb_reg_write),
        .write_data(wb_data),
        .read_data1(read_data_1),
        .read_data2(read_data_2)
    );

    // Instruction bit fields
    assign id_opcode = ifid_ir[6:0];
    assign id_funct7 = ifid_ir[31:25];
    assign id_funct3 = ifid_ir[14:12];
    assign id_rs1 = ifid_ir[19:15];
    assign id_rs2 = ifid_ir[24:20];

    // Default i_imm
    assign id_i_imm = { { 20{ ifid_ir[31] } }, ifid_ir[31:20] };
    assign id_shamt = { 27'b0, ifid_ir[24:20] };

    // B-type immediate value
    assign id_b_imm = { ifid_ir[31], ifid_ir[7], ifid_ir[30:25], ifid_ir[11:8], 1'b0 };

    // S-type immediate value
    assign id_s_imm = { { 20 {ifid_ir[31] } }, ifid_ir[31:25], ifid_ir[11:7] };

    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            // Reset ID/EX registers
            idex_branch_op <= `NOT_BRANCH;
            idex_mem_read <= 0;
            idex_mem_write <= 0;
            idex_mem_to_reg <= 0;
            idex_mem_data_width <= 0;
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
        end else if (idex_flush) begin
            idex_branch_op <= `NOT_BRANCH;
            idex_mem_read <= 0;
            idex_mem_write <= 0;
            idex_mem_to_reg <= 0;
            idex_mem_data_width <= 0;
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
            idex_rs1 <= id_rs1;
            idex_rs2 <= id_rs2;
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
                    case(id_funct3)
                        3'b000: begin //SB
                            idex_mem_data_width <= `MMU_WIDTH_BYTE;
                        end
                        3'b001: begin //SH
                            idex_mem_data_width <= `MMU_WIDTH_HALF;
                        end
                        3'b010: begin //SW
                            idex_mem_data_width <= `MMU_WIDTH_WORD;
                        end
                    endcase
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
    reg [31:0] alu_input_a;
    reg [31:0] alu_input_b;
    wire [31:0] alu_out;

    // Arithmetic Logic Unit (ALU)
    alu_module alu_inst(
        .alu_op(idex_alu_op),
        .alu_input_a(alu_input_a),
        .alu_input_b(alu_input_b),
        .alu_out(alu_out)
    );

    // Forwarding Unit.
    always @(*) begin
        if (exmem_rd != 0 && exmem_reg_write && exmem_rd == idex_rs1) begin
            alu_input_a = exmem_alu_out;
        end else if (memwb_rd != 0 && memwb_reg_write && memwb_rd == idex_rs1) begin
            alu_input_a = wb_data;
        end else begin
            alu_input_a = idex_data_read_1;
        end

        if (idex_alu_src == `ALU_SRC_FROM_IMM) begin
            alu_input_b = idex_imm;
        end else if (exmem_rd != 0 && exmem_reg_write && exmem_rd == idex_rs2) begin
            alu_input_b = exmem_alu_out;
        end else if (memwb_rd != 0 && memwb_reg_write && memwb_rd == idex_rs2) begin
            alu_input_b = wb_data;
        end else begin
            alu_input_b = idex_data_read_2;
        end
    end

    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            // Reset EX/MEM registers
            exmem_mem_to_reg <= 0;
            exmem_reg_write <= 0;
            exmem_mem_read <= 0;
            exmem_mem_write <= 0;
            exmem_mem_data_width <= 0;
            exmem_data_read_2 <= 32'b0;
            exmem_rd <= 5'b0;
            exmem_alu_out <= 0;
            exmem_branch_target <= 0;
            exmem_branch_taken <= 0;
        end else if (exmem_flush) begin
            exmem_mem_to_reg <= 0;
            exmem_reg_write <= 0;
            exmem_mem_read <= 0;
            exmem_mem_write <= 0;
            exmem_mem_data_width <= 0;
            exmem_data_read_2 <= 32'b0;
            exmem_rd <= 5'b0;
            exmem_alu_out <= 0;
            exmem_branch_target <= 0;
            exmem_branch_taken <= 0;
        end else begin
            exmem_mem_read <= idex_mem_read;
            exmem_mem_write <= idex_mem_write;
            exmem_mem_to_reg <= idex_mem_to_reg;
            exmem_mem_data_width <= idex_mem_data_width;
            exmem_rd <= idex_rd;
            exmem_reg_write <= idex_reg_write;
            exmem_alu_out <= alu_out;
            exmem_branch_target <= idex_pc + idex_imm;

            // Resolução de branch
            exmem_branch_taken <= 0;
            case (idex_branch_op)
                `BRANCH_BEQ: begin
                    if (alu_out == 32'b0) begin
                        exmem_branch_taken <= 1;
                    end
                end

                `BRANCH_BNE: begin
                    if (exmem_alu_out != 32'b0) begin
                        exmem_branch_taken <= 1;
                    end
                end

                //TODO: BGE, BGEU, BLT, BLTU, ...
                default: begin
                    exmem_branch_taken <= 0;
                end
            endcase
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
        end else if (memwb_flush) begin
            memwb_mem_data_read <= 32'b0;
            memwb_alu_out <= 32'b0;
            memwb_rd <= 5'b0;
            memwb_reg_write <= 0;
            memwb_mem_to_reg <= 0;
        end begin
            memwb_mem_data_read <= l1d_data_out;
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
    assign wb_data = memwb_mem_to_reg ? memwb_mem_data_read : memwb_alu_out;
    // -------------------------------------------------------------------------

endmodule
