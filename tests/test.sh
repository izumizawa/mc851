PROJECT_RTL_DIR="../rtl"

SOC_MODULES=\
"${PROJECT_RTL_DIR}/soc.v \
${PROJECT_RTL_DIR}/cpu.v \
${PROJECT_RTL_DIR}/mmu.v \
${PROJECT_RTL_DIR}/components/alu_module.v \
${PROJECT_RTL_DIR}/components/register_file.v \
${PROJECT_RTL_DIR}/components/ram.v \
${PROJECT_RTL_DIR}/components/rom.v \
${PROJECT_RTL_DIR}/components/l1_data_cache.v \
${PROJECT_RTL_DIR}/components/l1_instruction_cache.v"


echo "===============================Testing modules============================="

# Test ALU
iverilog -I ${PROJECT_RTL_DIR}/ -o modules/alu_module_tb.vvp modules/alu_module_tb.v ${PROJECT_RTL_DIR}/components/alu_module.v
vvp modules/alu_module_tb.vvp
echo ""

# Test MMU
iverilog -I ${PROJECT_RTL_DIR}/ -o modules/mmu_tb.vvp modules/mmu_tb.v ${PROJECT_RTL_DIR}/mmu.v ${PROJECT_RTL_DIR}/components/ram.v ${PROJECT_RTL_DIR}/components/rom.v
vvp modules/mmu_tb.vvp
echo ""

# Test Register File
iverilog -o modules/register_file.vvp modules/register_file_tb.v ${PROJECT_RTL_DIR}/components/register_file.v
vvp modules/register_file.vvp
echo ""

echo "===============================Testing integration=========================="

iverilog -I ${PROJECT_RTL_DIR}/ -o integration/forwarding_unit.vvp integration/forwarding_unit_tb.v ${SOC_MODULES}
vvp integration/forwarding_unit.vvp
echo ""

iverilog -I ${PROJECT_RTL_DIR}/ -o integration/multiply.vvp integration/multiply_tb.v ${SOC_MODULES}
vvp integration/multiply.vvp
echo ""

echo "===============================Testing instructions========================="

iverilog -I ${PROJECT_RTL_DIR}/ -o instructions/add.vvp instructions/add_tb.v ${SOC_MODULES}
vvp instructions/add.vvp
echo ""

iverilog -I ${PROJECT_RTL_DIR}/ -o instructions/addi.vvp instructions/addi_tb.v ${SOC_MODULES}
vvp instructions/addi.vvp
echo ""

iverilog -I ${PROJECT_RTL_DIR}/ -o instructions/and.vvp instructions/and_tb.v ${SOC_MODULES}
vvp instructions/and.vvp
echo ""

iverilog -I ${PROJECT_RTL_DIR}/ -o instructions/andi.vvp instructions/andi_tb.v ${SOC_MODULES}
vvp instructions/andi.vvp
echo ""

iverilog -I ${PROJECT_RTL_DIR}/ -o instructions/beq.vvp instructions/beq_tb.v ${SOC_MODULES}
vvp instructions/beq.vvp
echo ""

iverilog -I ${PROJECT_RTL_DIR}/ -o instructions/or.vvp instructions/or_tb.v ${SOC_MODULES}
vvp instructions/or.vvp
echo ""

iverilog -I ${PROJECT_RTL_DIR}/ -o instructions/ori.vvp instructions/ori_tb.v ${SOC_MODULES}
vvp instructions/ori.vvp
echo ""

iverilog -I ${PROJECT_RTL_DIR}/ -o instructions/sll.vvp instructions/sll_tb.v ${SOC_MODULES}
vvp instructions/sll.vvp
echo ""

iverilog -I ${PROJECT_RTL_DIR}/ -o instructions/slli.vvp instructions/slli_tb.v ${SOC_MODULES}
vvp instructions/slli.vvp
echo ""

iverilog -I ${PROJECT_RTL_DIR}/ -o instructions/slt.vvp instructions/slt_tb.v ${SOC_MODULES}
vvp instructions/slt.vvp
echo ""

iverilog -I ${PROJECT_RTL_DIR}/ -o instructions/slti.vvp instructions/slti_tb.v ${SOC_MODULES}
vvp instructions/slti.vvp
echo ""

iverilog -I ${PROJECT_RTL_DIR}/ -o instructions/sltiu.vvp instructions/sltiu_tb.v ${SOC_MODULES}
vvp instructions/sltiu.vvp
echo ""

iverilog -I ${PROJECT_RTL_DIR}/ -o instructions/sra.vvp instructions/sra_tb.v ${SOC_MODULES}
vvp instructions/sra.vvp
echo ""

iverilog -I ${PROJECT_RTL_DIR}/ -o instructions/srai.vvp instructions/srai_tb.v ${SOC_MODULES}
vvp instructions/srai.vvp
echo ""

iverilog -I ${PROJECT_RTL_DIR}/ -o instructions/srl.vvp instructions/srl_tb.v ${SOC_MODULES}
vvp instructions/srl.vvp
echo ""

iverilog -I ${PROJECT_RTL_DIR}/ -o instructions/srli.vvp instructions/srli_tb.v ${SOC_MODULES}
vvp instructions/srli.vvp
echo ""

iverilog -I ${PROJECT_RTL_DIR}/ -o instructions/sub.vvp instructions/sub_tb.v ${SOC_MODULES}
vvp instructions/sub.vvp
echo ""

iverilog -I ${PROJECT_RTL_DIR}/ -o instructions/xor.vvp instructions/xor_tb.v ${SOC_MODULES}
vvp instructions/xor.vvp
echo ""

iverilog -I ${PROJECT_RTL_DIR}/ -o instructions/xori.vvp instructions/xori_tb.v ${SOC_MODULES}
vvp instructions/xori.vvp
echo ""
