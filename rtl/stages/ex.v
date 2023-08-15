// EX: Execution or address calculation stage.
// modules = ["ALU", "Address Adder"]
// ARITHMETIC OPS
`define ALU_ADD     4'b0100
`define ALU_SUB     4'b0101
// LOGIC OPS
`define ALU_AND     4'b0110
`define ALU_OR      4'b0111
`define ALU_XOR     4'b1000


module alu_module (
    input  [3:0]   alu_input_op, 
    input  [31:0]  alu_input_a,
    input  [31:0]  alu_input_b,
    
    output [ 31:0]  alu_output_result
);

reg [31:0]   alu_register_result;

always @ (alu_input_op or alu_input_a or alu_input_b)
begin
    case (alu_input_op)
    // ARITHMETIC OPS
        `ALU_ADD :
            begin
                alu_register_result <= (alu_input_a + alu_input_b);
            end
        `ALU_SUB :
            begin
                alu_register_result <= (alu_input_a - alu_input_b);
            end
    // LOGIC OPS
        `ALU_AND :
            begin
                alu_register_result <= (alu_input_a && alu_input_b);
            end
        `ALU_OR :
            begin
                alu_register_result <= (alu_input_a || alu_input_b);
            end
        `ALU_XOR :
            begin
                alu_register_result <= (alu_input_a ^ alu_input_b);
            end
    endcase
end

assign alu_output_result = alu_register_result;

endmodule
