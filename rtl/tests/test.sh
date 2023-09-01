# Test ALU
echo "===Testing alu_tb.v========================================================"
iverilog -o alu_tb.vvp alu_tb.v ../components/alu.v
vvp alu_tb.vvp
echo ""

# Test Register File
echo "===Testing register_file_tb.v=============================================="
iverilog -o register_file.vvp register_file_tb.v ../components/register_file.v
vvp register_file.vvp
echo ""