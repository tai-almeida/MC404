.globl _start

_start:
    jal main
    

.bss
input: .skip 40
indice: .skip 40
.text

main:
    addi sp, sp, -4
    sw ra, 0(sp)
    la s2, indice
    jal read
    mv a0, a1
    jal para_decimal
    mv s1, a1
    jal percorre_lista
    jal para_string
    jal write
    lw ra, 0(sp)
    addi sp, sp, 4
    li a0, 0
    li a7, 93
    ecall

para_decimal:
    li a1, 0
    li t0, 10
    li t2, 45
    li t3, 1
    verifica_sinal:
        lb t1, 0(a0)
        beq t1, t2, negativo        # verifica se o primeiro digito eh '-'
        j loop_decimal
        negativo:
            li t3, -1
            addi a0, a0, 1
            j verifica_sinal
    loop_decimal:
        beq t1, t0, fim_decimal
        addi t1, t1, -48
        mul a1, a1, t0
        add a1, a1, t1

        addi a0, a0, 1
        j verifica_sinal
    fim_decimal:
        mul a1, a1, t3             # t3 = -1 se negativo e = 1 se positivo
        ret

percorre_lista:
    li a0, 0
    la s0, head_node
    percorre_nos:
        lw a2, 0(s0)                # carrega val1
        lw a3, 4(s0)                # carrega val2
        
        add a1, a2, a3
        beq a1, s1, encontrou       # val1 + val2 = input

        addi a0, a0, 1              # incrementa o contador
        lw t0, 8(s0)                # carrega o endereco do proximo no

        beqz t0, nao_existe         # se no aponta para NULL
        mv s0, t0                   # atualiza endereco para o do prox no
        j percorre_nos
    nao_existe:
        li a0, -1
        ret
    encontrou:
        ret

para_string:
    li t0, 0
    li t1, 45
    li t3, 10
    li t5, 100
    
    bge a0, t0, positivo
    li t4, -1
    sb t1, 0(s2)
    addi s2, s2, 1
    mul a0, a0, t4
    positivo:
        bge a0, t5, centena
        bge a0, t3, dezena
        j unidade
    centena:
        mv t4, a0
        div t4, t4, t5
        rem a0, a0, t5
        addi t6, t4, 48
        sb t6, 0(s2)
        addi s2, s2, 1
    dezena:
        mv t4, a0
        div t4, t4, t3
        rem a0, a0, t3
        addi t6, t4, 48
        sb t6, 0(s2)
        addi s2, s2, 1
        div t3, t3, t3
    unidade:
        mv t4, a0
        addi t6, t4, 48
        sb t6, 0(s2)
        addi s2, s2, 1
    fim:
        li t3, 10
        sb t3, 0(s2)
        ret

read:
    li a0, 0
    la a1, input
    li a2, 33
    li a7, 63
    ecall
    ret

write:
    li a0, 1
    la a1, indice
    li a2, 33
    li a7, 64
    ecall
    ret