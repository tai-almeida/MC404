.bss
output: .skip 35
string_puts: .skip 35
input: .skip 35
.text

.globl linked_list_search
.globl puts
.globl gets
.globl atoi
.globl itoa
.globl exit
.globl write
.globl read


linked_list_search:
    /* a0: endereco do no 
       a1: valor procurado */
    li t0, 0
    percorre_nos:
        lw a2, 0(a0)                # carrega val1
        lw a3, 4(a0)                # carrega val2
        
        add t1, a2, a3
        beq t1, a1, encontrou       # val1 + val2 = input

        addi t0, t0, 1              # incrementa o contador
        lw t1, 8(a0)                # carrega o endereco do proximo no

        beqz t1, nao_existe         # se no aponta para NULL
        mv a0, t1                   # atualiza endereco para o do prox no
        j percorre_nos
    nao_existe:
        li a0, -1
        ret
    encontrou:
        mv a0, t0
        ret


puts:
    # a0: buffer para impressao
    addi sp, sp, -4
    sw ra, 0(sp)

    mv t0, a0
    li t2, 0
    li a2, 0
    
    loop_puts:
        lb t1, 0(t0)        # carrega o primeiro digito na string enderecada
        addi t0, t0, 1
        addi t2, t2, 1
        beqz t1, fim_puts
        j loop_puts
fim_puts:
    li t1, 10
    # la t0, string_puts

    sb t1, 0(t0)
    addi t2, t2, 1
    mv a2, t2
    mv a1, a0
    # mv a2, t1
    jal write
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

write:
    li a0, 1
    li a7, 64
    ecall
    ret

gets:
    # a0: buffer de entrada
    addi sp, sp, -4
    sw ra, 0(sp)

    li t1, 10
    li t3, 0
    mv t0, a0
    mv t4, a0
    loop_gets:
        jal read
        lbu t2, 0(t0)
        beq t2, t1, fim_gets
        beqz t2, fim_gets
        addi t0, t0, 1
        # addi a0, a0, 1
        j loop_gets
fim_gets:
    sb t3, 0(t0)
    lw ra, 0(sp)
    addi sp, sp, 4
    mv a0, t4
    ret


read:
    li a0, 0
    mv a1, t0
    li a2, 1
    li a7, 63
    ecall 
    ret

atoi:
    /* input em a0 */
    li a1, 0
    li t0, 10
    li t2, 45
    li t3, 1
    verifica_sinal:
        lb t1, 0(a0)
        beq t1, t2, sinal_negativo        # verifica se o primeiro digito eh '-'
        j loop_decimal
        sinal_negativo:
            li t3, -1
            addi a0, a0, 1
            j verifica_sinal
    loop_decimal:
        beqz t1, fim_decimal
        addi t1, t1, -48
        mul a1, a1, t0
        add a1, a1, t1

        addi a0, a0, 1
        j verifica_sinal
    fim_decimal:
        mul a1, a1, t3             # t3 = -1 se negativo e = 1 se positivo
        mv a0, a1
        ret

itoa:
    /* a0: valor a ser convertido 
       a1: endereco da string
       a2: base numerica */
    li t0, 0
    li t1, 45
    li t3, 10
    la a4, output
    mv a3, a4
    
    blt a0, t0, negativo
    j else
    negativo:
        li t4, -1
        sb t1, 0(a3)
        addi a3, a3, 1
        mul a0, a0, t4
    else:
        beq a2, t3, base10
        j base16
    base10:
        li t1, 1000
        li t5, 100
        bge a0, t1, milhar
        bge a0, t5, centena
        bge a0, t3, dezena
        j unidade
        milhar:
            mv t4, a0
            div t4, t4, t1
            rem a0, a0, t1
            addi t6, t4, 48
            sb t6, 0(a3)
            addi a3, a3, 1
        centena:
            mv t4, a0
            div t4, t4, t5
            rem a0, a0, t5
            addi t6, t4, 48
            sb t6, 0(a3)
            addi a3, a3, 1
        dezena:
            mv t4, a0
            div t4, t4, t3
            rem a0, a0, t3
            addi t6, t4, 48
            sb t6, 0(a3)
            addi a3, a3, 1
            div t3, t3, t3
        unidade:
            mv t4, a0
            addi t6, t4, 48
            sb t6, 0(a3)
            addi a3, a3, 1
            j fim
    base16:
        li t1, 0x1000
        li t5, 256
        li t3, 16
        bge a0, t1, potencia3
        bge a0, t5, potencia2
        bge a0, t3, potencia1
        j potencia0
        potencia3:
            mv t4, a0
            div t4, t4, t1
            li t2, 10
            rem a0, a0, t1
            bge t4, t2, 1f
            addi t6, t4, 48
            j 2f
            1:
                addi t6, t4, 55
            2:
                sb t6, 0(a3)
                addi a3, a3, 1

        potencia2:
            mv t4, a0
            div t4, t4, t5
            li t2, 10
            rem a0, a0, t5
            bge t4, t2, 1f
            addi t6, t4, 48
            j 2f
            1:
                addi t6, t4, 55
            2:
                sb t6, 0(a3)
                addi a3, a3, 1
        potencia1:
            mv t4, a0
            div t4, t4, t3
            rem a0, a0, t3
            bge t4, t2, 1f
            addi t6, t4, 48
            j 2f
            1:
                addi t6, t4, 55
            2:
                sb t6, 0(a3)
                addi a3, a3, 1
                div t3, t3, t3
        potencia0:
            mv t4, a0
            bge t4, t2, 1f
            addi t6, t4, 48
            j 2f
            1:
                addi t6, t4, 55
            2:
                sb t6, 0(a3)
                addi a3, a3, 1
    fim:
        li t3, 10
        sb t3, 0(a3)
        mv a0, a4
        ret


    
exit:
    li a0, 0
    li a7, 93
    ecall