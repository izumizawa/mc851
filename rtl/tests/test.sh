echo "===============================Testing modules============================="

# Test ALU
iverilog -o ./modules/alu_module_tb.vvp ./modules/alu_module_tb.v ../components/alu_module.v
vvp ./modules/alu_module_tb.vvp
echo ""

# Test MMU
iverilog -I ../ -o modules/mmu_tb.vvp modules/mmu_tb.v ../mmu.v
vvp ./modules/mmu_tb.vvp
echo ""

# Test Register File
iverilog -o modules/register_file.vvp modules/register_file_tb.v ../components/register_file.v
vvp ./modules/register_file.vvp
echo ""

echo "===============================Testing integration=========================="

iverilog -I ../ -o integration/forwarding_unit.vvp integration/forwarding_unit_tb.v ../soc.v
vvp ./integration/forwarding_unit.vvp
echo ""

echo "===============================Testing instructions========================="

iverilog -I ../ -o instructions/addi.vvp instructions/addi_tb.v ../soc.v
vvp ./instructions/addi.vvp
echo ""

iverilog -I ../ -o instructions/beq.vvp instructions/beq_tb.v ../soc.v
vvp ./instructions/beq.vvp
echo ""
