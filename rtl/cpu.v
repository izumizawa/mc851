// Top model. Describes the whole CPU and its components.

module cpu (
    input clk, reset
);
    /***************************************************************************
     * IF Stage Logic
     **************************************************************************/
    reg [31:0] pc;
    @always @(posedge clk) begin
        ;
    end
    // -------------------------------------------------------------------------


    // --- IF/ID Register ---
    reg [31:0] ifid_pc;
    reg [31:0] ifid_ir;


    /***************************************************************************
     * ID Stage Logic
     **************************************************************************/
    @always @(posedge clk) begin
        ;
    end
    // -------------------------------------------------------------------------


    // --- ID/EX Register ---
    reg [31:0] idex_pc;
    // Sinais de controle
    reg idex_mem_to_reg;
    reg idex_reg_write;
    reg idex_branch;
    reg idex_mem_read;
    reg idex_mem_write;
    reg [1:0] idex_alu_src; // TODO: Ajustar conforme implementação da ALU
    reg [1:0] idex_alu_op;
    // ALU e Pipeline
    reg [31:0] idex_data_read_1;
    reg [31:0] idex_data_read_2;
    reg [ 4:0] idex_rs1;
	reg [ 4:0] idex_rs2;
	reg [ 4:0] idex_rd;
	reg [13:1] idex_imm;


    /***************************************************************************
     * EX Stage Logic
     **************************************************************************/
    @always @(posedge clk) begin
        ;
    end
    // -------------------------------------------------------------------------


    // --- EX/MEM Register ---
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


    /***************************************************************************
     * MEM Stage Logic
     **************************************************************************/
    @always @(posedge clk) begin
        ;
    end
    // -------------------------------------------------------------------------


    // --- MEM/WB Register ---
    reg [31:0] memwb_mem_data_read;
    reg [31:0] memwb_alu_out;
    reg [ 4:0] memwb_rd;


    /***************************************************************************
     * WB Stage Logic
     **************************************************************************/
    @always @(posedge clk) begin
        ;
    end
    // -------------------------------------------------------------------------

endmodule
