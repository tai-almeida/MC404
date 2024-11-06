.text
.globl my_function

my_function:
    addi sp, sp, -16
    sw ra, (sp)

    add t0, a0, a1      # SUM 1 em t0

    mv t1, t0
    mv t2, a0
    mv t5, a1
    mv a0, t1
    mv a1, t2
    

    jal mystery_function
    mv t3, a0

    sub t4, t5, t3      # DIFF 1 em t4 
    add t4, t4, a2      # SUM 2 em t4

    mv a0, t4
    mv a1, t5
    jal mystery_function


    sub t2, a2, a0      # DIFF 2 em t2
    add a0, t4, t2      # SUM 3 em a0

    lw ra, (sp)
    addi sp, sp, 16
    ret