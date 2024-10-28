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
    # beq a0, t4, to_hexa
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
    # 2:
    #     jal to_hexa
    #     j end

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

# to_hexa:
#     addi sp, sp, -16
#     sw ra, (sp)
    
    


write:
    addi sp, sp, -16
    sw ra, (sp)
    li t0, write_byte

    1:
        lbu t1, (sp)
        sb t1, (t0)
        li t2, aciona_write
        li t3, 1
        sb t3, (t2)

    2:
        lb t4, (t2)
        bnez t4, 2b

        addi a1, a1, -1
        addi sp, sp, 16
        bnez a1, 1b

    lw ra, (sp)
    addi sp, sp, 16
    ret



