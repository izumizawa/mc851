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
