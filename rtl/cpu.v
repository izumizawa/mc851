`include "define.v"

module cpu #(
    parameter ROM_ADDR_WIDTH = 8,  // 256×4B = 1 KiB
    parameter RAM_ADDR_WIDTH = 8,  // 256×4B = 1 KiB
    parameter BTN_ADDR_WIDTH = 8,
    parameter LED_ADDR_WIDTH = 8
) (
    input         clk,
    input         reset_n,
    input [31:0]  rom_data_out,
    input [31:0]  ram_data_out,
    input [31:0]  btn_data_out,
    output [ROM_ADDR_WIDTH-1:0] rom_address,
    output        rom_read_enable,
    output        ram_read_enable,
    output [31:0] ram_data_in,
    output [RAM_ADDR_WIDTH-1:0] ram_address,
    output        ram_write_enable,
    output        btn_read_enable,
    output [BTN_ADDR_WIDTH-1:0] btn_address,
    output [LED_ADDR_WIDTH-1:0] led_address,
    output        led_write_enable,
    output [31:0] led_data_in,
    output wire [31:0] uart_data
);

    // IF/ID Register
    reg [31:0] ifid_pc;
    reg [31:0] ifid_ir;

    // ID/EX Register
    reg [31:0] idex_pc;
    reg idex_reset;
    reg [3:0] idex_branch_op;
    reg idex_reg_write;
    reg idex_mem_to_reg;
    reg idex_alu_src;
    reg [ 3:0] idex_alu_op;
    reg [31:0] idex_data_read_1;
    reg [31:0] idex_data_read_2;
    reg [ 4:0] idex_rs1;
	reg [ 4:0] idex_rs2;
	reg [ 4:0] idex_rd;
	reg [31:0] idex_imm;

    reg [31:0] idex_ram_data_out;
    reg idex_mem_read;
    reg idex_mem_write;

    // EX/MEM Register
    reg exmem_reset;
    reg [3:0] exmem_branch_op;
    reg exmem_mem_to_reg;
    reg exmem_reg_write;

    reg [31:0] exmem_branch_target;
    //TODO: Substituir pelos nomes explícitos das flags conforme necessário (ex.: zero, negative, overflow, carry)
    reg [ 3:0] exmem_flags;
    reg [31:0] exmem_alu_out;
    reg [31:0] exmem_mem_data_in;
    reg [ 4:0] exmem_rd;

    reg exmem_mem_read;
    reg exmem_mem_write;

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
    reg branch_taken;
    assign rom_read_enable = 1;
    assign rom_address = pc[ROM_ADDR_WIDTH-1:2];

    always @(*) begin
        idex_reset = 0;
        exmem_reset = 0;
        branch_taken = 0;

        case (exmem_branch_op)
            `NOT_BRANCH: begin
                idex_reset = 0;
                exmem_reset = 0;
                branch_taken = 0;
            end
            `BRANCH_BEQ: begin
                if (exmem_alu_out == 32'b0) begin
                    idex_reset = 1;
                    exmem_reset = 1;
                    branch_taken = 1;
                end
            end
            `BRANCH_BNE: begin
                if (exmem_alu_out != 32'b0) begin
                    idex_reset = 1;
                    exmem_reset = 1;
                    branch_taken = 1;
                end
            end
            `BRANCH_BGE: begin
                if (exmem_alu_out == 1'b0) begin
                    idex_reset = 1;
                    exmem_reset = 1;
                    branch_taken = 1;
                end
            end
            `BRANCH_BGEU: begin
                if (exmem_alu_out == 1'b0) begin
                    idex_reset = 1;
                    exmem_reset = 1;
                    branch_taken = 1;
                end
            end
            `BRANCH_BLT: begin
                if (exmem_alu_out == 1'b1) begin
                    idex_reset = 1;
                    exmem_reset = 1;
                    branch_taken = 1;
                end
            end
            `BRANCH_BLTU: begin
                if (exmem_alu_out == 1'b1) begin
                    idex_reset = 1;
                    exmem_reset = 1;
                    branch_taken = 1;
                end
            end
            `BRANCH_JAL: begin
                idex_reset = 1;
                exmem_reset = 1;
                branch_taken = 1;
            end
            `BRANCH_JALR: begin
                idex_reset = 1;
                exmem_reset = 1;
                branch_taken = 1;
            end
            default: begin
                idex_reset = 0;
                exmem_reset = 0;
                branch_taken = 0;
            end
        endcase
    end

    always @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            pc <= 0;
            ifid_pc <= 32'b0;
            ifid_ir <= `RISCV_NOP;
        end else begin
            ifid_pc <= pc;
            ifid_ir <= rom_data_out;

            if (branch_taken) begin
                pc <= exmem_branch_target;
            end else begin
                pc <= pc + 4;
            end
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
    wire [31:0] id_j_imm;
    wire [31:0] id_shamt;
    wire [ 4:0] id_rs1;
	wire [ 4:0] id_rs2;

    wire [31:0] read_data_1;
    wire [31:0] read_data_2;

    wire [31:0] register_file_uart_data;
    assign uart_data = register_file_uart_data;

    register_file regfile(
        .clk(clk),
        .read_reg1(id_rs1),
        .read_reg2(id_rs2),
        .write_reg(memwb_rd),
        .write_enable(memwb_reg_write),
        .write_data(wb_data),
        .read_data1(read_data_1),
        .read_data2(read_data_2),
        .uart_data(register_file_uart_data)
    );

    // Assigns
    assign id_opcode = ifid_ir[6:0];
    assign id_funct7 = ifid_ir[31:25];
    assign id_funct3 = ifid_ir[14:12];
    assign id_rs1 = ifid_ir[19:15];
    assign id_rs2 = ifid_ir[24:20];

    // Default i_imm
    assign id_i_imm = { { 20{ ifid_ir[31] } }, ifid_ir[31:20] };
    assign id_shamt = { 27'b0, ifid_ir[24:20] };
    // B-type b_imm
    assign id_b_imm = { ifid_ir[31], ifid_ir[7], ifid_ir[30:25], ifid_ir[11:8], 1'b0 };
    assign id_s_imm = { { 20 {ifid_ir[31] } }, ifid_ir[31:25], ifid_ir[11:7] };
    assign id_j_imm = { { 11 {ifid_ir[31] } }, ifid_ir[31], ifid_ir[19:12], ifid_ir[20], ifid_ir[30:21], 1'b0 };

    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            // Reset ID/EX registers
            idex_branch_op <= `NOT_BRANCH;
            idex_mem_read <= 0;
            idex_mem_write <= 0;
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
        end else if(idex_reset) begin
            // Reset ID/EX registers
            idex_branch_op <= `NOT_BRANCH;
            idex_mem_read <= 0;
            idex_mem_write <= 0;
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
            idex_rs1 <= id_rs1;
            idex_rs2 <= id_rs2;
            idex_rd <= ifid_ir[11:7];
            idex_imm <= { { 20 { id_i_imm[11] } }, id_i_imm[11:0] };
            idex_mem_to_reg <= 0;
            idex_reg_write <= 0;
            idex_mem_read <= 0;
            idex_mem_write <= 0;
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
                        idex_alu_op <= `ALU_SLT;
                    end else if (id_funct3 == 3'b011) begin
                        idex_alu_op <= `ALU_SLTU;
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

                // Load instructions
                7'b0000011: begin
                    idex_mem_to_reg <= 1;
                    idex_reg_write <= 1;
                    idex_mem_read <= 1;
                    idex_alu_src <= `ALU_SRC_FROM_IMM;
                    idex_alu_op <= `ALU_ADD;
                    idex_imm <= id_i_imm;
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
                    end else if (id_funct3 == `BRANCH_BGE) begin //BGE
                        idex_alu_op <= `ALU_SLT;
                        idex_branch_op <= `BRANCH_BGE;
                    end else if (id_funct3 == `BRANCH_BGEU) begin //BGEU
                        idex_alu_op <= `ALU_SLTU;
                        idex_branch_op <= `BRANCH_BGEU;
                    end else if (id_funct3 == `BRANCH_BLT) begin //BLT
                        idex_alu_op <= `ALU_SLT;
                        idex_branch_op <= `BRANCH_BLT;
                    end else if (id_funct3 == `BRANCH_BLTU) begin //BLTU
                        idex_alu_op <= `ALU_SLTU;
                        idex_branch_op <= `BRANCH_BLTU;
                    end else if (id_funct3 == `BRANCH_BNE) begin //BNE
                        idex_alu_op <= `ALU_SUB;
                        idex_branch_op <= `BRANCH_BNE;
                    end
                end

                // JAL instruction
                7'b1101111: begin
                    idex_reg_write <= 1;
                    idex_alu_src <= `ALU_SRC_FROM_REG;
                    idex_alu_op <= `ALU_ADD;
                    idex_imm <= id_j_imm;
                    idex_branch_op <= `BRANCH_JAL;
                end

                // JALR instruction
                7'b1100111: begin
                    idex_reg_write <= 1;
                    idex_alu_src <= `ALU_SRC_FROM_REG;
                    idex_alu_op <= `ALU_ADD;
                    idex_imm <= id_i_imm;
                    idex_branch_op <= `BRANCH_JALR;
                end
            endcase
        end
    end
    // -------------------------------------------------------------------------


    /***************************************************************************
     * Execute (EX) stage
     **************************************************************************/
    reg [31:0] ex_jalr_offset;
    reg [31:0] alu_input_a;
    reg [31:0] alu_input_b;
    wire [31:0] alu_out;

    // Modules instantiations
    alu_module alu_inst(
        .alu_input_op(idex_alu_op),
        .alu_input_a(alu_input_a),
        .alu_input_b(alu_input_b),
        .alu_output_result(alu_out) // Wire always required in modules output
    );

    // Forwarding Unit.
    always @(*) begin
        if (exmem_rd != 0 && exmem_reg_write && exmem_rd == idex_rs1) begin
            if (idex_branch_op == `BRANCH_JAL || idex_branch_op == `BRANCH_JALR) begin
                alu_input_a = idex_pc;
                ex_jalr_offset = exmem_alu_out + idex_imm;
            end else begin
                alu_input_a = exmem_alu_out;
                ex_jalr_offset = 0;
            end
        end else if (memwb_rd != 0 && memwb_reg_write && memwb_rd == idex_rs1) begin
            if (idex_branch_op == `BRANCH_JAL || idex_branch_op == `BRANCH_JALR) begin
                alu_input_a = idex_pc;
                ex_jalr_offset = wb_data + idex_imm;
            end else begin
                alu_input_a = wb_data;
                ex_jalr_offset = 0;
            end
        end else begin
            alu_input_a = idex_data_read_1;
            ex_jalr_offset = 0;
        end

        if (idex_alu_src == `ALU_SRC_FROM_IMM) begin
            alu_input_b = idex_imm;
        end else if (exmem_rd != 0 && exmem_reg_write && exmem_rd == idex_rs2) begin
            alu_input_b = exmem_alu_out;
        end else if (memwb_rd != 0 && memwb_reg_write && memwb_rd == idex_rs2) begin
            alu_input_b = wb_data;
        end else if (idex_branch_op == `BRANCH_JAL || idex_branch_op == `BRANCH_JALR) begin
            alu_input_b = 4;
        end else begin
            alu_input_b = idex_data_read_2;
        end
    end

    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            // Reset EX/MEM registers
            exmem_branch_op <= `NOT_BRANCH;
            exmem_mem_to_reg <= 0;
            exmem_reg_write <= 0;
            exmem_mem_read <= 0;
            exmem_mem_write <= 0;
            exmem_flags <= 4'b0;
            exmem_mem_data_in <= 32'b0;
            exmem_rd <= 5'b0;
            exmem_alu_out <= 0;
            exmem_branch_target <= 0;
        end else if (exmem_reset) begin
            exmem_branch_op <= `NOT_BRANCH;
            exmem_mem_to_reg <= 0;
            exmem_reg_write <= 0;
            exmem_mem_read <= 0;
            exmem_mem_write <= 0;
            exmem_flags <= 4'b0;
            exmem_mem_data_in <= 32'b0;
            exmem_rd <= 5'b0;
            exmem_alu_out <= 0;
            exmem_branch_target <= 0;
        end else begin
            exmem_mem_data_in <= idex_data_read_2;
            exmem_branch_op <= idex_branch_op;
            exmem_mem_read <= idex_mem_read;
            exmem_mem_write <= idex_mem_write;
            exmem_mem_to_reg <= idex_mem_to_reg;
            exmem_rd <= idex_rd;
            exmem_reg_write <= idex_reg_write;
            exmem_alu_out <= alu_out;

            if (idex_branch_op == `BRANCH_JALR) begin
                exmem_branch_target <= ex_jalr_offset;
            end else begin
                exmem_branch_target <= idex_pc + idex_imm;
            end
        end
    end
    // -------------------------------------------------------------------------


    /***************************************************************************
     * Memory access (MEM) stage
     **************************************************************************/
    localparam RAM_SELECT   = 23'b00;
    localparam RAM_RANGE    = 9;
    localparam BTN_SELECT   = 23'b01;
    localparam BTN_RANGE    = 9;
    localparam LED_SELECT   = 23'b10;
    localparam LED_RANGE    = 9;

    assign ram_address = exmem_alu_out[RAM_ADDR_WIDTH-1:0];
    assign ram_data_in = exmem_mem_data_in;
    assign ram_read_enable = (exmem_alu_out[31:RAM_RANGE] == RAM_SELECT) ? exmem_mem_read : 0;
    assign ram_write_enable = (exmem_alu_out[31:RAM_RANGE] == RAM_SELECT) ? exmem_mem_write : 0;

    assign btn_address = exmem_alu_out[BTN_ADDR_WIDTH-1:0];
    assign btn_read_enable = (exmem_alu_out[31:BTN_RANGE] == BTN_SELECT) ? exmem_mem_read : 0;

    assign led_address = exmem_alu_out[LED_ADDR_WIDTH-1:0];
    assign led_data_in = exmem_mem_data_in;
    assign led_write_enable = (exmem_alu_out[31:LED_RANGE] == LED_SELECT) ? exmem_mem_write : 0;

    always @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            // Reset MEM/WB registers
            memwb_mem_data_read <= 32'b0;
            memwb_alu_out <= 32'b0;
            memwb_rd <= 5'b0;
            memwb_reg_write <= 0;
            memwb_mem_to_reg <= 0;
        end else begin
            memwb_mem_data_read <= 32'b0;
            memwb_rd <= exmem_rd;
            memwb_reg_write <= exmem_reg_write;
            memwb_mem_to_reg <= exmem_mem_to_reg;
            memwb_alu_out <= 0;

            if (exmem_mem_read) begin
                if(btn_read_enable) begin
                    memwb_mem_data_read <= btn_data_out;
                end else begin
                    memwb_mem_data_read <= ram_data_out;
                end
            end else begin
                memwb_alu_out <= exmem_alu_out;
            end
        end
    end
    // -------------------------------------------------------------------------


    /***************************************************************************
     * Writeback (WB) stage
     **************************************************************************/
    always @(*) begin
        if(memwb_mem_to_reg) begin
            wb_data <= memwb_mem_data_read;
        end else begin
            wb_data <= memwb_alu_out;
        end
    end
    // -------------------------------------------------------------------------

endmodule
