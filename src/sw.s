li t0, 0x0 # RAM address to save
li s0, 0xA
nop
nop
sw s0, 0(t0)
lw t1, 0(t0)
