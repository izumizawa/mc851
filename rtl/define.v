`ifndef _define_v_

// -------------------------- MMU definitions
`define MMU_WIDTH_BYTE 2'b00
`define MMU_WIDTH_HALF 2'b01
`define MMU_WIDTH_WORD 2'b11
// -------------------------- Pipeline Control signals
`define ALU_SRC_FROM_REG 1'b0
`define ALU_SRC_FROM_IMM 1'b1

// ALU_op: ALU operation
//--------------------------- ARITHMETIC
`define ALU_ADD     4'b0000
`define ALU_SUB     4'b0001
// -------------------------- LOGIC
`define ALU_AND     4'b0010
`define ALU_OR      4'b0011
`define ALU_XOR     4'b0100
// -------------------------- SHIFT
`define ALU_SLL     4'b0101
`define ALU_SRL     4'b0110
`define ALU_SRA     4'b0111
// -------------------------- COMPARE
`define ALU_SLT     4'b1000
`define ALU_SLTU    4'b1001
// -------------------------- NOP
`define ALU_NOP     4'b1111

// -------------------------- BRANCH
`define BRANCH_BEQ      3'b000
`define BRANCH_BNE      3'b001
`define NOT_BRANCH      3'b010
`define BRANCH_BLT      3'b100
`define BRANCH_BGE      3'b101
`define BRANCH_BLTU     3'b110
`define BRANCH_BGEU     3'b111

`endif
