.bss
x_atual: .word
y_atual: .word
z_atual: .word
steer: .skip 1
.align 4
pilha_programa: .skip 1024
fim_pilha_programa: 
pilha_isr: .skip 1024
fim_pilha_isr:
.align 2

.text
.align 4

# Enderecos perifericos
.set ATIVA_GPS, 0xFFFF0100
.set CAMERA, 0xFFFF0101
.set SENSOR_ULTRASONICO, 0xFFFF0102
.set ANGULO_EULER_X, 0xFFFF0104
.set ANGULO_EULER_Y, 0xFFFF0108
.set ANGULO_EULER_Z, 0xFFFF010C
.set POSICAO_X, 0xFFFF0110
.set POSICAO_Y, 0xFFFF0114
.set POSICAO_Z, 0xFFFF0118
.set DIST_OBSTACULO, 0xFFFF011C
.set DIR_STEER, 0xFFFF0120
.set DIR_ENGINE, 0xFFFF0121
.set FREIO_MAO, 0xFFFF0122
.set IMAGEM, 0xFFFF0124


int_handler:
    ###### Syscall and Interrupts handler ######

    # <= Implement your syscall handler here
    # salva contexto
    csrrw sp, mscratch, sp 
    addi sp, sp, -64
    sw t0, (sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    sw t3, 12(sp)

    csrr t0, a7         # verifica syscall chamada

    li t1, 10                   # engine e steering
    beq t0, t1, trata_engine_steer
    li t1, 11                   # freio de mao
    beq t0, t1, trata_freio_de_mao
    li t1, 12                   # camera
    beq t0, t1, trata_camera
    li t1, 15                   # gps
    beq t0, t1, trata_gps

    trata_engine_steer:
        li t0, DIR_ENGINE
        sb a0, (t0)
        li t1, DIR_STEER
        sb a1, (t1)
        j fim_isr
    trata_freio_de_mao:
        li t0, FREIO_MAO
        sb a0, (t0)
        j fim_isr
    trata_camera:
        li t0, CAMERA
        sb a0, (t0)
        j fim_isr
    trata_gps:
        li t0, ATIVA_GPS
        li t1, 1
        sb t1, (t0)
        busy_waiting_gps:
            lw t1, (t0)
            bnez t1, busy_waiting_gps
        
        li t0, POSICAO_X
        li t1, POSICAO_Y
        li t2, POSICAO_Z

        lw t3, (t0)
        sw t3, (a0)
        
        lw t3, (t1)
        sw t3, (a1)

        lw t3, (t2)
        sw t3, (a2)
    
    fim_isr:
        # recupera contexto
        lw t3, 12(sp)
        lw t2, 8(sp)
        lw t1, 4(sp)
        lw t0, (sp)
        
        csrr t0, mepc  # load return address 
        addi t0, t0, 4 
        csrw mepc, t0  # stores the return address back on mepc

        addi sp, sp, 64
        csrrw sp, mscratch, sp
        mret          


.globl _start
_start:

    la t0, int_handler  # Load the address of the routine that will handle interrupts
    csrw mtvec, t0      # (and syscalls) on the register MTVEC to set
                        # the interrupt array.

    la sp, fim_pilha_programa
    la t0, fim_pilha_isr
    csrw mscratch, t0

    # habilita interrupoes externas e globais
    csrr t1, mie
    li t2, 0x800
    ori t1, t1, t2
    csrw mie, t2

    csrr t1, mstatus
    ori t1, t1, 0x8
    csrw mstatus, t1

    la t0, user_main
    csrw mepc, t0
    mret

.globl control_logic
control_logic:
    # implement your control logic here, using only the defined syscalls
    addi sp, sp, -16
    sw ra, (sp)

    li a7, 15
    la a3, steer
    la a0, x_atual
    la a1, y_atual
    la a2, z_atual
    ecall

    lw t0, (a0)
    lw t1, (a1)
    li t2, (a2)
    
    jal calcula_angulo

calcula_angulo:
    li t3, 100
    bgt t0, t3, direita         # x > 100: vira para a direita
    li t3, 50
    blt t0, t3, esquerda        # x < 50: vira para esquerda

    reto:
        li a0, 1
        li a1, 0
        li a7, 10
        ecall
        j end 
    direita:
        li a0, 1
        li a1, 1
        li a7, 10




