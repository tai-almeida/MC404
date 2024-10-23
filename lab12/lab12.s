.globl _start
_start:
    jal main
    li a0, 0
    li a7, 93
    ecall

.bss
string_input: .skip 35

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
    li t0, trigger_read         # leitura
    sb t1, (t0)                 # carrega status 1 em t0
    
    1:
        # li t0, trigger_read    
        # li t1, 1
        # sb t1, (t0)            
        
        # li t1, read_byte
        lb t2, (t0)
        bnez t2, 1b            # continua lendo enquanto nao tiver finalizado

    
    li t0, read_byte
    lb a0, (t0)            # le byte com numero da operacao

    li t2, 1
    sb t2, (t0)
    li t0, read_byte       # le \n

    lw ra, (sp)
    addi sp, sp, 16
    ret


puts:
    addi sp, sp, -16
    sw ra, 0(sp)
    la s1, string_input
    li t2, 1
    sb t2, (t0)
    sb t2, (t1)
    li a1, 0
    1:
        
        li t1, trigger_read
        li t2, read_byte
        li t3, write_byte
        addi a1, a1, 1
        sb t2, (s1)
        addi s1, s1, 1
        lb t2, (t0)
        bnez t2, 1b
    
fim_puts:
    li t1, 10
    sb t1, 0(t0)
    addi a1, a1, 1

    write:
        loop_puts:
        li t0, trigger_write
        sub s1, s1, a1
        lbu t1, (s1)
        sb t1, (t3)
        li t3, write_byte
        addi s1, s1, 1
        lb t4, (t0)
        bnez t4, write

    lw ra, 0(sp)
    addi sp, sp, 16
    ret
        

