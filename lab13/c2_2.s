.text
.globl middle_value_int
.globl middle_value_short
.globl middle_value_char
.globl value_matrix

middle_value_int:
    addi sp, sp, -16
    sw ra, (sp)
    li t0, 2
    divu a1, a1, t0
    li t1, 0
    0:
        bge t1, a1, 1f
        addi a0, a0, 4
        addi t1, t1, 1
        j 0b
    1:
        lw a0, (a0)
        lw ra, (sp)
        addi sp, sp, 16
        ret

middle_value_short:
    addi sp, sp, -16
    sw ra, (sp)
    li t0, 2
    divu a1, a1, t0
    li t1, 0
    0:
        bge t1, a1, 1f
        addi a0, a0, 2
        addi t1, t1, 1
        j 0b
    1:
        lw a0, (a0)
        lw ra, (sp)
        addi sp, sp, 16
        ret

middle_value_char:
    addi sp, sp, -16
    sw ra, (sp)
    li t0, 2
    divu a1, a1, t0
    li t1, 0
    0:
        bge t1, a1, 1f
        addi a0, a0, 1
        addi t1, t1, 1
        j 0b
    1:
        lw a0, (a0)
        lw ra, (sp)
        addi sp, sp, 16
        ret

value_matrix:
    addi sp, sp, -16
    sw ra, (sp)
    li t0, 0        # i
    li t1, 0        # j
    li t2, 12
    li t3, 42
    loop_i:
        bgt t0, t2, fim_matriz
        beq t0, a1, 0f
        j loop_j
        0:
            beq t1, a2, encontrou
        
        loop_j:
            bge t1, t3, prox_linha
            beq t0, a1, 0f
            j 1f
            0:
                beq t1, a2, encontrou
            1:
                addi t1, t1, 1
                addi a0, a0, 4
                j loop_j
        prox_linha:
            li t1, 0
            addi t0, t0, 1
            j loop_i
    fim_matriz:
        lw ra, (sp)
        addi sp, sp, 16
        ret

    encontrou:
        lw a0, (a0)
        lw ra, (sp)
        addi sp, sp, 16
        ret