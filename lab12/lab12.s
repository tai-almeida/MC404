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
    beq a0, t5, 3f
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
    3:
        jal res_algebrico
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
    li a7, 1

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

        li t5, 45
        beq t3, t5, negative
        j continue
        negative:
            li a7, -1

            j 1b
        continue:
        addi t3, t3, -48
        mul a0, a0, t4
        add a0, a0, t3
        addi a1, a1, 1

        j 1b
    
    3:                      # passa para hexadecimal
        bgt a7, zero, 4f
        addi a0, a0, -1
        xori a0, a0, -1              # complemento de dois 
        ori a0, a0, -1
    4:
        rem a5, a0, a4
        div a0, a0, a4
        addi a2, a2, 1
        
        addi sp, sp, -16        #guarda digito na pilha
        sw a5, (sp)

        bnez a0, 4b
    
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

res_algebrico:
    addi sp, sp, -16
    sw ra, (sp)

    mv fp, sp

    li a1, 0
    li t4, 10
    li t5, 32
    li a0, 0
    li a3, 0
    li a6, 1

    0:
        li t0, aciona_read         # ativar leitura
        li t1, 1
        sb t1, (t0)
    1:
        lb t2, (t0)             # le status da leitura
        bnez t2, 1b             # espera ate concluir a leitura

        
        li t0, read_byte
        lb t3, (t0)
        addi a3, a3, 1
        
        li a2, 45
        beq t3, a2, verifica_sinal
        j cont
        verifica_sinal:
            beq a3, t1, negativo
            j cont
            negativo:
                li a6, -1
                j 0b
        cont:
            beq t3, t5, debug
            beq t3, t4, 3f

            li a2, 42
            beq t3, a2, multiplicacao
            li a2, 43
            beq t3, a2, soma
            li a2, 45
            beq t3, a2, subtracao
            li a2, 47
            beq t3, a2, divisao

            addi t3, t3, -48
            mul a0, a0, t4
            add a0, a0, t3
            
            j 0b
    debug:
        j 0b

    multiplicacao:
        mul a0, a0, a6
        addi sp, sp, -16
        sw a0, (sp)
        li a0, 0
        li a7, 1

        0:
            li t0, aciona_read         # ativar leitura
            li t1, 1
            sb t1, (t0)
        1:
            lb t2, (t0)             # le status da leitura
            bnez t2, 1b             # espera ate concluir a leitura

            
            li t0, read_byte
            lb t3, (t0)
            addi a3, a3, 1
        
            li a2, 45
            beq t3, a2, mult_sinal
            j cont_mult
            mult_sinal:
                li a7, -1
                j 0b
            cont_mult:
                beq t3, t5, 2f
                beq t3, t4, 3f

                addi t3, t3, -48
                mul a0, a0, t4
                add a0, a0, t3

        2:
            j 0b
        3:
            lw a1, (sp)
            addi sp, sp, 16

            mul a0, a0, a7
            mul a0, a0, a1
            bgt a0, zero, 4f
            li a6, -1
            mul a0, a0, a7
        4:

            addi sp, sp, -16
            sw t4, (sp)
            j 5f
    soma:
        mul a0, a0, a6
        addi sp, sp, -16
        sw a0, (sp)
        li a0, 0
        li a7, 1

        0:
            li t0, aciona_read         # ativar leitura
            li t1, 1
            sb t1, (t0)
        1:
            lb t2, (t0)             # le status da leitura
            bnez t2, 1b             # espera ate concluir a leitura

            
            li t0, read_byte
            lb t3, (t0)
        
            li a2, 45
            beq t3, a2, soma_sinal
            j cont_soma
            soma_sinal:
                li a7, -1
                j 0b
            cont_soma:
                beq t3, t5, 2f
                beq t3, t4, 3f

                addi t3, t3, -48
                mul a0, a0, t4
                add a0, a0, t3

        2:
            j 0b
        3:
            lw a1, (sp)
            addi sp, sp, 16
            mul a0, a0, a7
            add a0, a0, a1
            bgt a0, zero, 4f
            li a6, -1
            mul a0, a0, a6
        4:
            addi sp, sp, -16
            sw t4, (sp)
            j 5f
        

    subtracao:
        mul a0, a0, a6
        addi sp, sp, -16
        sw a0, (sp)
        li a0, 0
        li a7, 1

        0:
            li t0, aciona_read         # ativar leitura
            li t1, 1
            sb t1, (t0)
        1:
            lb t2, (t0)             # le status da leitura
            bnez t2, 1b             # espera ate concluir a leitura

            
            li t0, read_byte
            lb t3, (t0)
        
            li a2, 45
            beq t3, a2, sub_sinal
            j cont_sub
            sub_sinal:
                li a7, -1
                j 0b
            cont_sub:
                beq t3, t5, 2f
                beq t3, t4, 3f

                addi t3, t3, -48
                mul a0, a0, t4
                add a0, a0, t3

        2:
            j 0b
        3:
            lw a1, (sp)
            addi sp, sp, 16

            mul a0, a0, a7
            sub a0, a1, a0
            
            bgt a0, zero, 4f
            li a6, -1
            mul a0, a0, a6
        4:
            addi sp, sp, -16
            sw t4, (sp)
            j 5f
    divisao:
        mul a0, a0, a6
        addi sp, sp, -16
        sw a0, (sp)
        li a0, 0
        li a7, 1

        0:
            li t0, aciona_read         # ativar leitura
            li t1, 1
            sb t1, (t0)
        1:
            lb t2, (t0)             # le status da leitura
            bnez t2, 1b             # espera ate concluir a leitura

            
            li t0, read_byte
            lb t3, (t0)

            li a2, 45
            beq t3, a2, div_sinal
            j cont_div
            div_sinal:
                li a7, -1
                j 0b
            cont_div:
                beq t3, t5, 2f
                beq t3, t4, 3f

                addi t3, t3, -48
                mul a0, a0, t4
                add a0, a0, t3

        2:
            j 0b
        3:
            lw a1, (sp)
            addi sp, sp, 16

            mul a0, a0, a7
            div a0, a1, a0
            bgt a0, zero, 4f
            li a6, -1
            mul a0, a0, a7
        4:

            addi sp, sp, -16
            sw t4, (sp)
    5:
        # terminou de ler a expressao
        li t4, 10
        rem a3, a0, t4
        div a0, a0, t4
        addi a3, a3, 48

        addi sp, sp, -16
        sw a3, (sp)

        bnez a0, 5b
        bgt a6, zero, 6f
        li a6, 45
        addi sp, sp, -16
        sw a6, (sp) 

        6:
            lw a3, (sp)
            addi sp, sp, 16

            li t0, write_byte
            sb a3, (t0)

            li t1, 1
            li t0, aciona_write
            sb t1, (t0)
        7:
            lb t2, (t0)
            bnez t2, 7b

            bne sp, fp, 6b

    mv sp, fp
    lw ra, (sp)
    addi sp, sp, 16
    ret