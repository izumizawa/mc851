main:
    addi t1, zero, 0              # t1 = 0, contador
    addi t3, zero, 1                 # t3 = 1
    li s0, 512                    # s0 = 0x400, endereco do botao
    li s1, 1024                    # s1 = 0x800, endereco do led
    nop
    nop

loop:
    lw t2, 0(s0)               # t2 = mem[memory_addr] valor do buffer do botao
    nop
    nop
    nop
    nop
    bne t2, t3, loop                 # Se nao for 1, volta para loop

    # Se o botao foi pressionado adiciona o contador
    addi t1, t1, 1                   # t1 = t1 + 1
    nop
    nop
    sw t1, 0(s1)                    # Salva o contador no led_address
    j loop                          # Volta para o loop
