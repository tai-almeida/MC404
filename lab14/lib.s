.bss
.globl _system_time
_system_time: .word
.align 4
pilha_programa: .skip 1024
fim_pilha_prog:             
pilha_isr: .skip 1024          
fim_pilha_isr: 

.text
.align 2
.globl _start
.globl play_note

.set ATIVA_GPT, 0xFFFF0100        # gatilha o GPT a ler quando "1" eh armazenado
.set TEMPO_GPT, 0xFFFF0104        # armazena o tempo da ultima leitura
.set INTERRUPCAO_GPT, 0xFFFF0108  # gpt gera uma interrupcao externa depois de v ms
.set CANAL_MIDI, 0xFFFF0300
.set ID_INSTRUMENTO, 0xFFFF0302
.set NOTA,0xFFFF0304
.set VELOCIDADE_NOTA, 0xFFFF0305
.set DURACAO_NOTA, 0xFFFF0306

_start:
    # registrar a isr
    la t0, main_isr        
    csrw mtvec, t0

    # configuracao do mscratch (armazenamento temporario durante interrupcoes)
    la sp, fim_pilha_prog
    la t0, fim_pilha_isr
    csrw mscratch, t0               #  mscratch aponta para a base da pilha

    li a0, ATIVA_GPT
    li t0, 1
    sb t0, (a0)
    busy_waiting_start:
        lb t0, (a0)
        bnez t0, busy_waiting_start
    
    li t0, INTERRUPCAO_GPT
    li t1, 100
    sw t1, (t0)

    # habilitar interrupcoes externas
    csrr t1, mie
    li t2, 0x800
    or t1, t1, t2
    csrw mie, t2

    # habilitar interrupcoes globais (controle mestre para permitir ou desativar todas 
    # as interrupcoes no sistema)
    csrr t1, mstatus
    ori t1, t1, 0x8
    csrw mstatus, t1

    jal main


main_isr:
    # salva o contexto 
    csrrw sp, mscratch, sp          # troca sp e mscratch
    addi sp, sp, -64
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    sw a7, 28(sp)
    sw t0, 32(sp)
    sw t1, 36(sp)
    sw t2, 40(sp)
    sw t3, 44(sp)
    sw t4, 48(sp)
    sw t5, 52(sp)
    sw t6, 56(sp)

    # tratar interrupcao
    li a0, ATIVA_GPT
    li t0, 1
    sb t0, (a0)
    busy_waiting:
        lb t0, (a0)
        bnez t0, busy_waiting
    
    la a1, _system_time
    lw t0, (a1)
    addi t0, t0, 100
    sw t0, (a1)

    li t0, INTERRUPCAO_GPT
    li t1, 100
    sw t1, (t0)

    # recupera contexto
    lw t6, 56(sp)
    lw t5, 52(sp)
    lw t4, 48(sp)
    lw t3, 44(sp)
    lw t2, 40(sp)
    lw t1, 36(sp)
    lw t0, 32(sp)
    lw a7, 28(sp)
    lw a6, 24(sp)
    lw a5, 20(sp)
    lw a4, 16(sp)
    lw a3, 12(sp)
    lw a2, 8(sp)
    lw a1, 4(sp)
    lw a0, 0(sp)
    addi sp, sp, 64
    csrrw sp, mscratch, sp
    mret

play_note:
    /* a0: ch (canal)
       a1: inst (id do instrumento)
       a2: note (nota musical) 
       a3: vel (velocidade da nota)
       a4: dur (duracao da nota) */

    addi sp, sp, -16
    sw ra, (sp)

    li t0, CANAL_MIDI
    sb a0, (t0)

    li t1, ID_INSTRUMENTO
    sh a1, (t1)

    li t2, NOTA
    sb a2, (t2)

    li t3, VELOCIDADE_NOTA
    sb a3, (t3)

    li t4, DURACAO_NOTA
    sh a4, (t4)

    lw ra, (sp)
    addi sp, sp, 16
    ret


