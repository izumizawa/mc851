# Test ALU
iverilog -o alu_tb.vvp alu_tb.v ../components/alu.v
vvp alu_tb.vvp