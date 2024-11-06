.text
.globl swap_int
.globl swap_short
.globl swap_char

swap_int:
    addi sp, sp, -16
    sw ra, (sp)
    lw t0, (a0)
    lw t1, (a1)
    sw t1, (a0)
    sw t0, (a1)
    lw ra, (sp)
    addi sp, sp, 16
    li a0, 0
    ret

swap_short:
    addi sp, sp, -16
    sw ra, (sp)
    lw t0, (a0)
    lw t1, (a1)
    sw t1, (a0)
    sw t0, (a1)
    lw ra, (sp)
    addi sp, sp, 16
    li a0, 0
    ret

swap_char:
    addi sp, sp, -16
    sw ra, (sp)
    lw t0, (a0)
    lw t1, (a1)
    sw t1, (a0)
    sw t0, (a1)
    lw ra, (sp)
    addi sp, sp, 16
    li a0, 0
    ret