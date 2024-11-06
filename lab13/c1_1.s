.data
.globl my_var
my_var: .word 10

.text
.globl increment_my_var

increment_my_var:
    addi sp, sp, -16
    sw ra, (sp)
    la a0, my_var
    lw t0, (a0)
    addi t0, t0, 1
    sw t0, (a0)
    lw ra, (sp)
    addi sp, sp, 16
    ret