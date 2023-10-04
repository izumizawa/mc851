# Test ALU
echo "===Testing alu_tb.v========================================================"
iverilog -o ./modules/alu_module_tb.vvp ./modules/alu_module_tb.v ../components/alu_module.v
vvp ./modules/alu_module_tb.vvp
echo ""

# Test MMU
echo "===Testing mmu_tb.v========================================================"
iverilog -I ../ -o modules/mmu_tb.vvp modules/mmu_tb.v ../mmu.v
vvp ./modules/mmu_tb.vvp
echo ""

# Test Register File
echo "===Testing register_file_tb.v=============================================="
iverilog -o modules/register_file.vvp modules/register_file_tb.v ../components/register_file.v
vvp ./modules/register_file.vvp
echo ""

# Test instructions
echo "===Testing addi_tb.v=============================================="
iverilog -I ../ -o instructions/addi.vvp instructions/addi_tb.v ../soc.v
vvp ./instructions/addi.vvp
echo ""
