echo "===============================Testing modules============================="

# Test ALU
iverilog -o ./modules/alu_module_tb.vvp ./modules/alu_module_tb.v ../components/alu_module.v
vvp ./modules/alu_module_tb.vvp
echo ""

# Test MMU
iverilog -I ../ -o modules/mmu_tb.vvp modules/mmu_tb.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./modules/mmu_tb.vvp
echo ""

# Test Register File
iverilog -o modules/register_file.vvp modules/register_file_tb.v ../components/register_file.v
vvp ./modules/register_file.vvp
echo ""

# Test button peripheral
iverilog -o modules/btn.vvp modules/btn_tb.v ../components/btn.v
vvp ./modules/btn.vvp
echo ""

# Test LED
iverilog -o modules/led.vvp modules/led_tb.v ../components/led.v
vvp ./modules/led.vvp
echo ""

# echo "===============================Testing integration=========================="

iverilog -I ../ -o integration/forwarding_unit.vvp integration/forwarding_unit_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./integration/forwarding_unit.vvp
echo ""

iverilog -I ../ -o integration/multiply.vvp integration/multiply_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./integration/multiply.vvp
echo ""

echo "===============================Testing instructions========================="

iverilog -I ../ -o instructions/add.vvp instructions/add_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/add.vvp
echo ""

iverilog -I ../ -o instructions/addi.vvp instructions/addi_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/addi.vvp
echo ""

iverilog -I ../ -o instructions/and.vvp instructions/and_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/and.vvp
echo ""

iverilog -I ../ -o instructions/andi.vvp instructions/andi_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/andi.vvp
echo ""

iverilog -I ../ -o instructions/beq.vvp instructions/beq_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/beq.vvp
echo ""

iverilog -I ../ -o instructions/bge.vvp instructions/bge_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/bge.vvp
echo ""

iverilog -I ../ -o instructions/bgeu.vvp instructions/bgeu_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/bgeu.vvp
echo ""

iverilog -I ../ -o instructions/blt.vvp instructions/blt_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/blt.vvp
echo ""

iverilog -I ../ -o instructions/bltu.vvp instructions/bltu_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/bltu.vvp
echo ""

iverilog -I ../ -o instructions/bne.vvp instructions/bne_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/bne.vvp
echo ""

iverilog -I ../ -o instructions/jal.vvp instructions/jal_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/jal.vvp
echo ""

iverilog -I ../ -o instructions/jalr.vvp instructions/jalr_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/jalr.vvp
echo ""

iverilog -I ../ -o instructions/or.vvp instructions/or_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/or.vvp
echo ""

iverilog -I ../ -o instructions/ori.vvp instructions/ori_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/ori.vvp
echo ""

iverilog -I ../ -o instructions/sll.vvp instructions/sll_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/sll.vvp
echo ""

iverilog -I ../ -o instructions/slli.vvp instructions/slli_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/slli.vvp
echo ""

iverilog -I ../ -o instructions/slt.vvp instructions/slt_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/slt.vvp
echo ""

iverilog -I ../ -o instructions/slti.vvp instructions/slti_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/slti.vvp
echo ""

iverilog -I ../ -o instructions/sltiu.vvp instructions/sltiu_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/sltiu.vvp
echo ""

iverilog -I ../ -o instructions/sra.vvp instructions/sra_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/sra.vvp
echo ""

iverilog -I ../ -o instructions/srai.vvp instructions/srai_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/srai.vvp
echo ""

iverilog -I ../ -o instructions/srl.vvp instructions/srl_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/srl.vvp
echo ""

iverilog -I ../ -o instructions/srli.vvp instructions/srli_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/srli.vvp
echo ""

iverilog -I ../ -o instructions/sub.vvp instructions/sub_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/sub.vvp
echo ""

iverilog -I ../ -o instructions/xor.vvp instructions/xor_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/xor.vvp
echo ""

iverilog -I ../ -o instructions/xori.vvp instructions/xori_tb.v ../soc.v ../cpu.v ../components/alu_module.v ../components/register_file.v ../mmu.v ../components/ram.v ../components/rom.v ../components/btn.v ../components/led.v
vvp ./instructions/xori.vvp
echo ""
