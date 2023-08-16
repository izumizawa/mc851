// EX: Execution or address calculation stage.
// modules = ["ALU", "Address Adder"]
`include "define.v"


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
        `ALU_ADD: alu_register_result <= (alu_input_a + alu_input_b);
        `ALU_SUB: alu_register_result <= (alu_input_a - alu_input_b);
    // LOGIC OPS
        `ALU_AND: alu_register_result <= (alu_input_a && alu_input_b);
        `ALU_OR:  alu_register_result <= (alu_input_a || alu_input_b);
        `ALU_XOR: alu_register_result <= (alu_input_a ^ alu_input_b);
    // SHIFT OPS
        `ALU_SLL:  alu_register_result <= alu_input_a << alu_input_b[4:0]; // need to set a range otherwise it will binary extend the number
        `ALU_SRL:  alu_register_result <= alu_input_a >> alu_input_b[4:0];
        `ALU_SRA:  alu_register_result <= $signed(alu_input_a) >>> alu_input_b[4:0];
    endcase
end

assign alu_output_result = alu_register_result;

endmodule
