.globl _start

_start:
    jal main
    li a0, 0
    li a7, 93
    ecall

.text
.set valor_steer, 0xFFFF0120
.set direcao_engine, 0xFFFF0121

.align 2

main:
    addi sp, sp, -16
    sw ra, 0(sp)
    li a1, -127
    jal set_steer
    li a2, direcao_engine   # inicializa motor
    li t4, 1
    sb t4, (a2)             # liga o carro
    
    li t1, 18500            # virar para a esquerda por 18500 segundos
    jal set_delay

    li t1, 40000            # seguir reto por 40000 segundos
    li a1, 0
    jal set_steer
    jal set_delay

    lw ra, 0(sp)
    addi sp, sp, 16
    ret


set_steer:
    /* Seta estercamento do volante */
    addi sp, sp, -16
    sw ra, 0(sp)
    li a0, valor_steer
    sb a1, 0(a0)
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

set_delay:
    /* Seta tempo de delay para determinado estercamento */
    addi sp, sp, -16
    sw ra, 0(sp)
    li t0, 0
    0:
        addi t0, t0, 1
        blt t0, t1, 0b
    lw ra, 0(sp)
    addi sp, sp, 16
    ret



