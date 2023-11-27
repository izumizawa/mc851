module alu_module (
    input [3:0] alu_op,
    input [31:0] alu_input_a,
    input [31:0] alu_input_b,
    output reg [31:0] alu_out
);
    always @(*) begin
        alu_out = 0;

        case (alu_op)
        // ARITHMETIC OPS
            `ALU_ADD: alu_out = (alu_input_a + alu_input_b);
            `ALU_SUB: alu_out = (alu_input_a - alu_input_b);
        // LOGIC OPS
            `ALU_AND: alu_out = (alu_input_a & alu_input_b);
            `ALU_OR:  alu_out = (alu_input_a | alu_input_b);
            `ALU_XOR: alu_out = (alu_input_a ^ alu_input_b);
        // SHIFT OPS
            `ALU_SLL:  alu_out = alu_input_a << alu_input_b[4:0]; // need to set a range otherwise it will binary extend the number
            `ALU_SRL:  alu_out = alu_input_a >> alu_input_b[4:0];
            `ALU_SRA:  alu_out = $signed(alu_input_a) >>> alu_input_b[4:0];
        // COMPARE OPS
            `ALU_SLT:  alu_out = ($signed(alu_input_a) < $signed(alu_input_b)) ? 1 : 0;
            `ALU_SLTU: alu_out = (alu_input_a < alu_input_b) ? 1 : 0;
            default: ;
        endcase
    end
endmodule
