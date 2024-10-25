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
    beq a0, t2, puts        
    # beq t1, t3, reverte
    # beq t1, t4, to_hexa
    # beq t1, t5, expressao
    end:
        lw ra, (sp)
        addi sp, sp, 16
        ret

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
        bne t2, t3, 1b
    lw ra, (sp)
    addi sp, sp, 16


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


