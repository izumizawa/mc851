main:
    nop
    nop
    li t0, 0x400 # btn1 address
    lw t1, 0(t0) # load btn1 value
    