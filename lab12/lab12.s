.globl _start
_start:
    jal main
    li a0, 0
    li a7, 93
    ecall

.text
.set trigger_write,0xFFFF0100
.set write_byte, 0xFFFF0101
.set trigger_read, 0xFFFF0102
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
    li t1, 1
    sb t1, (t0)            # carrega status 1 em t0
    1:
        li t0, trigger_read    # leitura
        li t1, read_byte
        lb t2, (t0)
        bnez t2, 1b            # continua lendo enquanto nao tiver finalizado

    li t1, read_byte
    lb a0, (t3)            # le byte com numero da operacao

    li t1, read_byte       # le \n

    lw ra, (sp)
    addi sp, sp, 16
    ret


puts:
    addi sp, sp, -16
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
    sb t1, 0(t0)
    addi t2, t2, 1
    mv a2, t2
    mv a1, a0
    
    lw ra, 0(sp)
    addi sp, sp, 16
    ret
        

