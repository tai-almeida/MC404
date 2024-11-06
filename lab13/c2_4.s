.text
.globl node_op

node_op:
    addi sp, sp, -16
    sw ra, (sp)

    lw t0, (a0)
    lbu t1, 4(a0)
    lbu t2, 5(a0)
    lhu t3, 6(a0)

    add a0, t0, t1
    sub a0, a0, t2
    add a0, a0, t3

    lw ra, (sp)
    addi sp, sp, 16
    ret