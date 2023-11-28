main:
	addi t0, zero, 12
    jalr x1, 0(t0)

not_here:
    addi t0, zero, 0

here:
    addi t0, zero, 1
