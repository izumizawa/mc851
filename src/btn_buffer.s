main:
    nop
    nop
    li t0, 512 # btn1 address
    lw t1, 0(t0) # load btn1 value
    