module ex_to_mem (
input wire clk,
input wire enabled,

input wire mem_to_reg,
input wire reg_write,
input wire branch,
input wire mem_read,
input wire mem_write,
input wire [31:0] alu_result,
input wire [31:0] write_data,
input wire [31:0] rd,

output wire mem_to_reg_out,
output wire reg_write_out,
output wire branch_out,
output wire mem_read_out,
output wire mem_write_out,
output wire [31:0] alu_result_out,
output wire [31:0] write_data_out,
output wire [31:0] rd_out
);

reg var_mem_to_reg;
reg var_reg_write;
reg var_branch;
reg var_mem_read;
reg var_mem_write;
reg [31:0] var_alu_result;
reg [31:0] var_write_data;
reg [31:0] var_rd;

always @(posedge clk) begin
    if (enabled) begin
        var_mem_to_reg <= mem_to_reg;
        var_reg_write <= reg_write;
        var_branch <= branch;
        var_mem_read <= mem_read;
        var_mem_write <= mem_write;
        var_alu_result <= alu_result;
        var_write_data <= write_data;
        var_rd <= rd;
    end else begin
        var_mem_to_reg <= 0;
        var_reg_write <= 0;
        var_branch <= 0;
        var_mem_read <= 0;
        var_mem_write <= 0;
        var_alu_result <= 0;
        var_write_data <= 0;
        var_rd <= 0;
    end
end

assign mem_to_reg_out = var_mem_to_reg;
assign reg_write_out = var_reg_write;
assign branch_out = var_branch;
assign mem_read_out = var_mem_read;
assign mem_write_out = var_mem_write;
assign alu_result_out = var_alu_result;
assign write_data_out = var_write_data;
assign rd_out = var_rd;

endmodule