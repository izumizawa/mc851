.globl main

.text
main:
    addi a1, zero, 2
    addi a2, zero, 2
    addi a0, zero, 0
    addi t0, zero, 0

# a0 = a1 * a2
multiply:
    add a0, a0, a1  # a0 = a0 + a1
    add t0, t0, 1   # t0 = t0 + 1
    bne t0, a2, multiply # if t0 == a2 goto end

end:
    mv t1, a0
