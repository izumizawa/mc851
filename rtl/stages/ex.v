// EX: Execution or address calculation stage.
// modules = ["ALU", "Address Adder"]
`define ALU_ADD     4'b0100


module alu_1 (
    input  [3:0]   alu_input_op, 
    input  [31:0]  alu_input_a,
    input  [31:0]  alu_input_b,
    
    output [ 31:0]  alu_output_result
);

reg [31:0]   alu_register_result;

always @ (alu_input_op or alu_input_a or alu_input_b)
begin
    case (alu_input_op)
           `ALU_ADD : 
           begin
                alu_register_result <= (alu_input_a + alu_input_b);
           end
    endcase
end

assign alu_output_result = alu_register_result;

endmodule
