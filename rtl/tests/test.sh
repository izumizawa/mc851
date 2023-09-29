# Test ALU
echo "===Testing alu_tb.v========================================================"
iverilog -o alu_module_tb.vvp alu_module_tb.v ../components/alu_module.v
vvp alu_module_tb.vvp
echo ""

# Test MMU
echo "===Testing mmu_tb.v========================================================"
iverilog -I ../ -o mmu_tb.vvp mmu_tb.v ../mmu.v
vvp mmu_tb.vvp
echo ""

# Test Register File
echo "===Testing register_file_tb.v=============================================="
iverilog -o register_file.vvp register_file_tb.v ../components/register_file.v
vvp register_file.vvp
echo ""

# Test SOC
echo "===Testing soc_tb.v=============================================="
iverilog -I ../ -o soc.vvp soc_tb.v ../soc.v
vvp soc.vvp
echo ""
