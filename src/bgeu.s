main:
    addi t0, zero, -1       # t0 = 0xFF
    addi t1, zero, 0        # t1 = 0x00
    bgeu t0, t1, main
