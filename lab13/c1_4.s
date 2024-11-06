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
    add a0, a1, a2      # b+c
    sub a0, a0, a5      # b+c - f
    add a0, a0, a7      # b+c-f + h

    lw t0, 8(sp)
    add a0, a0, t0      # b + c - f + h + k 
    lw t0, 16(sp)
    sub a0, a0, t0      # b + c - f + h + k - m
    ret