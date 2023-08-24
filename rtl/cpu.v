// Top model. Describes the whole CPU and its components.

module cpu (
    input clk, reset
);
    // IF/ID Register
    reg [31:0] ifid_pc;
    reg [31:0] ifid_ir;

    // ID/EX Register
    reg [31:0] idex_pc;
    // ... sinais de controle
    reg idex_mem_to_reg;
    reg idex_reg_write;
    reg idex_branch;
    reg idex_mem_read;
    reg idex_mem_write;
    reg idex_alu_src;
    reg [ 3:0] idex_alu_op; // TODO: Ajustar conforme implementação da ALU
    // ... ALU e Pipeline
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
    always @(posedge clk) begin
        ;
    end
    // -------------------------------------------------------------------------


    /***************************************************************************
     * Execute (EX) stage
     **************************************************************************/
    always @(posedge clk) begin
        ;
    end
    // -------------------------------------------------------------------------


    /***************************************************************************
     * Memory access (MEM) stage
     **************************************************************************/
    always @(posedge clk) begin
        ;
    end
    // -------------------------------------------------------------------------


    /***************************************************************************
     * Writeback (WB) stage
     **************************************************************************/
    always @(posedge clk) begin
        ;
    end
    // -------------------------------------------------------------------------

endmodule
