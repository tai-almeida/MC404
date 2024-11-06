.text
.globl fill_array_int
.globl fill_array_short
.globl fill_array_char

fill_array_int:
    addi sp, sp, -16
    sw ra, (sp)

    addi sp, sp, -400
    li t0, 0
    li t1, 100
    0:
        sw t0, (sp)
        addi sp, sp, 4
        addi t0, t0, 1
        blt t0, t1, 0b
    
    li t2, 4
    mul t0, t0, t2
    sub sp, sp, t0
    mv a0, sp
    jal mystery_function_int

    addi sp, sp, 400

    lw ra, (sp)
    addi sp, sp, 16 
    ret

fill_array_short:
    addi sp, sp, -16
    sw ra, (sp)

    addi sp, sp, -200
    li t0, 0
    li t1, 100
    0:
        sh t0, (sp)
        addi sp, sp, 2
        addi t0, t0, 1
        blt t0, t1, 0b
    
    li t2, 2
    mul t0, t0, t2
    sub sp, sp, t0
    mv a0, sp
    jal mystery_function_short

    addi sp, sp, 200
    
    lw ra, (sp)
    addi sp, sp, 16 
    ret

fill_array_char:
    addi sp, sp, -16
    sw ra, (sp)

    addi sp, sp, -100
    li t0, 0
    li t1, 100
    0:
        sb t0, (sp)
        addi sp, sp, 1
        addi t0, t0, 1
        blt t0, t1, 0b
    
    sub sp, sp, t0
    mv a0, sp
    jal mystery_function_char

    addi sp, sp, 100
    
    lw ra, (sp)
    addi sp, sp, 16 
    ret