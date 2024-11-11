.bss
.align 4
pilha_programa: .skip 1024
pilha_isr: .skip 1024 
.align 2

.text
.globl _start
.globl _system_time

_start:
    csrrw sp, mscratch, sp
    addi sp, sp, -64
    sw a0, (sp)
    sw a1, 4(sp)