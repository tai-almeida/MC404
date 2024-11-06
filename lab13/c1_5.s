.text
.globl operation

operation:
    /* a0: a
       a1: b
       a2: c
       a3: d
       a4: e
       a5: f
       a6: g
       a7: h
        */
    
    lw t5, (sp)        #  desempilha i
    lw t4, 4(sp)        #  desempilha j
    lw t3, 8(sp)        #  desempilha k
    lw t2, 12(sp)        #  desempilha l
    lw t1, 16(sp)        #  desempilha m
    lw t0, 20(sp)        #  desempilha n
    addi sp, sp, 32

    addi sp, sp, -16
    sw ra, (sp)

    addi sp, sp, -32
    sw a0, 20(sp)
    sw a1, 16(sp)
    sw a2, 12(sp)
    sw a3, 8(sp)
    sw a4, 4(sp)
    sw a5, (sp)

    mv a0, t0           # n
    mv a1, t1           # m
    mv a2, t2           # l
    mv a3, t3           # k
    mv a4, t4           # j
    mv a5, t5           # i
    mv t6, a6
    mv a6, a7           # h
    mv a7, t6           # g
    

    jal mystery_function
    
    addi sp, sp, 32
    lw ra, (sp)
    addi sp, sp, 16
    addi sp, sp, -32
    ret