module mem_to_wb (
input wire clk,
input wire enabled,

input wire mem_to_reg,
input wire reg_write,
input wire [31:0] mem_data,
input wire [31:0] alu_result,
input wire [31:0] rd,

output wire mem_to_reg_out,
output wire reg_write_out,
output wire [31:0] mem_data_out,
output wire [31:0] alu_result_out,
output wire [31:0] rd_out
);

reg var_mem_to_reg;
reg var_reg_write;
reg [31:0] var_mem_data;
reg [31:0] var_alu_result;
reg [31:0] var_rd;

always @(posedge clk) begin
    if (enabled) begin
        var_mem_to_reg <= mem_to_reg;
        var_reg_write <= reg_write;
        var_mem_data <= mem_data;
        var_alu_result <= alu_result;
        var_rd <= rd;
    end else begin
        var_mem_to_reg <= 0;
        var_reg_write <= 0;
        var_mem_data <= 0;
        var_alu_result <= 0;
        var_rd <= 0;
    end
end

assign mem_to_reg_out = var_mem_to_reg;
assign reg_write_out = var_reg_write;
assign mem_data_out = var_mem_data;
assign alu_result_out = var_alu_result;
assign rd_out = var_rd;

endmodule