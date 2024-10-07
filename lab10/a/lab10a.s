.text

.globl linked_list_search
.globl puts
.globl gets
.globl atoi
.globl itoa
.globl exit

linked_list_search:

puts:
    mv a2, a0
    1:
        addi sp, sp, -4
        sw ra, 0(sp)
        lb a1, 0(a2)        # carrega o primeiro digito na string enderecada
        beqz a1, fim_linha
        addi a2, a2, 1
        j 1b

fim_linha:
    li a0

write:
    li a0, 1
    li