.globl _start
_start:
    jal main
    li a0, 0
    li a7, 93
    ecall

.text
.set aciona_write,0xFFFF0100
.set write_byte, 0xFFFF0101
.set aciona_read, 0xFFFF0102
.set read_byte, 0xFFFF0103


main:
    addi sp, sp, -16
    sw ra, (sp)

    jal get_operacao
    
    li t2, 1
    li t3, 2
    li t4, 3
    li t5, 4
    # verifica qual operacao executar
    beq a0, t2, 0f        
    beq a0, t3, 1f
    beq a0, t4, 2f
    # beq a0, t5, expressao
    end:
        lw ra, (sp)
        addi sp, sp, 16
        ret
    0:
        jal puts
        j end
    1:
        jal reverte
        j end
    2:
        jal to_hexa
        j end

get_operacao:
    addi sp, sp, -16
    sw ra, (sp)

    1:
        li t0, aciona_read
        li t1, 1
        sb t1, (t0)
    2:                          # busy waiting
        lb t1, (t0)
        bnez t1, 2b

        li t0, read_byte
        lb t2, (t0)

        li t3, 10
        beq t2, t3, 3f
        addi a0, t2, -48
        j 1b
    3:
        lw ra, (sp)
        addi sp, sp, 16
        ret


puts:
    /* operacao 1: imprime na saida serial o que ler na entrada */
    addi sp, sp, -16
    sw ra, (sp)
    1:
        li t0, aciona_read         # ativar leitura
        li t1, 1
        sb t1, (t0)
    2:
        lb t2, (t0)             # le status da leitura
        bnez t2, 2b             # espera ate concluir a leitura

        
        li t0, read_byte
        lb t3, (t0)
        li t0, write_byte
        sb t3, (t0)

        li t1, 1
        li t0, aciona_write
        sb t1, (t0)
    3:
        lb t2, (t0)
        bnez t2, 3b

        li t4, 10
        bne t3, t4, 1b
    
    
    lw ra, (sp)
    addi sp, sp, 16
    ret

reverte:
    addi sp, sp, -16
    sw ra, (sp)
    mv fp, sp

    li t0, 10
    addi sp, sp, -16
    sw t0, (sp)

    1:
        li t0, aciona_read         # ativar leitura
        li t1, 1
        sb t1, (t0)
    2:
        lb t2, (t0)             # le status da leitura
        bnez t2, 2b             # espera ate concluir a leitura

        
        li t0, read_byte
        lb t3, (t0)

        addi sp, sp, -16
        sw t3, (sp)

        li t4, 10
        bne t3, t4, 1b

        addi sp, sp, 16     # pula o \n
    
    3:                          # desempilhar e escrever
        lw t3, (sp)
        addi sp, sp, 16

        li t0, write_byte
        sb t3, (t0)

        li t1, 1
        li t0, aciona_write
        sb t1, (t0)
    4:
        lb t2, (t0)
        bnez t2, 4b
        bne sp, fp, 3b
    
    lw ra, (sp)
    addi sp, sp, 16
    ret

to_hexa:
    addi sp, sp, -16
    sw ra, (sp)

    li a0, 0
    li a1, 0
    li a2, 1
    li a3, 16
    li a4, 16
    li a6, 0
    li t6, 1

    mv fp, sp

    1:
        li t0, aciona_read         # ativar leitura
        li t1, 1
        sb t1, (t0)
    2:
        lb t2, (t0)             # le status da leitura
        bnez t2, 2b             # espera ate concluir a leitura

        
        li t0, read_byte
        lb t3, (t0)

        li t4, 10
        beq t3, t4, 3f

        addi t3, t3, -48
        mul a0, a0, t4
        add a0, a0, t3
        addi a1, a1, 1

        j 1b
    
    3:                      # passa para hexadecimal
        rem a5, a0, a4
        div a0, a0, a4
        addi a2, a2, 1
        
        addi sp, sp, -16        #guarda digito na pilha
        sw a5, (sp)

        bnez a0, 3b
    
    li a3, 16
    li t5, 9
    li t6, 10
    li t4, 0

    5:                      # converte para string
        lw a0, (sp)
        addi sp, sp, 16
    6:        
        bgt a0, t5, 7f
        j 8f
        7:
            addi a0, a0, 55
            j 9f
    8:
        addi a0, a0, 48
    9:
        addi t4, t4, 1
        li t0, write_byte
        sb a0, (t0)

        li t1, 1
        li t0, aciona_write
        sb t1, (t0)
    10:
        lb t2, (t0)
        bnez t2, 10b
        bne sp, fp, 5b

    li t3, 10
    li t0, write_byte
    sb t3, (t0)

    li t1, 1
    li t0, aciona_write
    sb t1, (t0)

    11:
        lb t2, (t0)
        bnez t2, 11b

    mv sp, fp
    lw ra, (sp)
    addi sp, sp, 16
    ret

# write:
#     addi sp, sp, -16
#     sw ra, (sp)
#     li t0, write_byte

#     1:
#         lbu t1, (sp)
#         sb t1, (t0)
#         li t2, aciona_write
#         li t3, 1
#         sb t3, (t2)

#     2:
#         lb t4, (t2)
#         bnez t4, 2b

#         addi a1, a1, -1
#         addi sp, sp, 16
#         bnez a1, 1b

#     lw ra, (sp)
#     addi sp, sp, 16
#     ret



