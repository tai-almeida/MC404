.globl _start

_start:
    jal main

.bss
input: .skip 20
resultado: .skip 20
decodificado: .skip 20
erro: .skip 20

.text

main:
    addi sp, sp, -4
    sw ra, 0(sp)
    la s4, resultado
    la s0, input

    # bloco calculo de parity
    li a2, 5                     # le 5 bytes 
    jal read
    mv s0, a1
    jal to_decimal
    jal p1
    jal p2
    jal p3
    jal formata_paridade

    # decodificacao segunda linha
    li a2, 8
    jal read
    mv s0, a1
    la s5, decodificado
    jal get_digitos
    jal decode

    jal confere_p1
    jal confere_p2
    jal confere_p3
    la s6, erro
    li t0, 1
    beq t0, a5, ha_erro
    beq t0, a6, ha_erro
    beq t0, a7, ha_erro
    j end
    ha_erro:
        addi t0, t0, 48
        sb t0, 0(s6)
        li t0, 10
        sb t0, 1(s6)
        j end 
    end:
        # impressoes
        li t0, 0
        addi t0, t0, 48
        sb t0, 0(s6)
        li t0, 10
        sb t0, 1(s6)
        jal write_encode
        jal write_decode
        jal write_erro
        li a0, 0
        li a7, 93
        ecall


read:
    li a0, 0
    la a1, input
    li a7, 63
    ecall
    ret

to_decimal:
    # guardo cada digito em cada registador
    #li t0, 1000                 # converte o primeiro digito
    lbu t1, 0(s0)
    addi t1, t1, -48
    mv a1, t1 

    #li t0, 100                  # converte o segundo digito
    lbu t2, 1(s0)
    addi t2, t2, -48
    mv a2, t2 

    #li t0, 10                   # converte o terceiro digito
    lbu t3, 2(s0)
    addi t3, t3, -48
    mv a3, t3
                
    lbu t4, 3(s0)               # coonverte o quarto digito
    addi t4, t4, -48
    mv a4, t4

    ret

p1:
    # soma digitos d1, d2 e d4
    add a0, a1, a2
    add a0, a0, a4

    # extrai o resto da divisao por dois (se impar != 0)
    li t0, 2
    rem a0, a0, t0

    # p1 = resto (armazena em s1)
    mv s1, a0
    ret

p2:
    # soma digitos d1, d3 e d4
    add a0, a1, a3
    add a0, a0, a4

    # extrai o resto da divisao por dois (se impar != 0)
    li t0, 2
    rem a0, a0, t0

    # p2 = resto (armazena em s2)
    mv s2, a0
    ret

p3:
    # soma digitos d1, d2 e d4
    add a0, a2, a3
    add a0, a0, a4

    # extrai o resto da divisao por dois (se impar != 0)
    li t0, 2
    rem a0, a0, t0

    # p3 = resto (armazena em s3)
    mv s3, a0
    ret

formata_paridade:
    # linha 1 do output (s4)
    #p1p2d1p3d2d3d4
                  
    addi s1, s1, 48                 # primeiro digito: p1
    sb s1, 0(s4)

    addi s2, s2, 48                 # segundo digito: p2
    sb s2, 1(s4)

    addi a1, a1, 48                 # terceiro digito: d1
    sb a1, 2(s4)

    addi s3, s3, 48                 # quarto digito: p3
    sb s3, 3(s4)

    addi a2, a2, 48                 # quinto digito: d2
    sb a2, 4(s4)

    addi a3, a3, 48                 # sexto digito: d3
    sb a3, 5(s4)

    addi a4, a4, 48                 # terceiro digito: d4
    sb a4, 6(s4)

    li t0, 10                       # insere '\n'
    sb t0, 7(s4)
    ret

get_digitos:
    # guardo cada digito em cada registador
    #li t0, 1000                 # extrai p1
    lbu t0, 0(s0)
    addi t0, t0, -48
    mv s1, t0 

    #li t0, 100                  # extrai p2
    lbu t1, 1(s0)
    addi t1, t1, -48
    mv s2, t1 
     
    lbu t2, 2(s0)               # extrai d1
    addi t2, t2, -48
    mv a1, t2
                
    lbu t3, 3(s0)               # extrai p3
    addi t3, t3, -48
    mv s3, t3

    lbu t4, 4(s0)               # extrai d2
    addi t4, t4, -48
    mv a2, t4
                
    lbu t5, 5(s0)               # extrai d3
    addi t5, t5, -48
    mv a3, t5

    lbu t6, 6(s0)               # extrai d4
    addi t6, t6, -48
    mv a4, t6
    ret

decode:
    addi a1, a1, 48
    sb a1, 0(s5)
    addi a2, a2, 48
    sb a2, 1(s5)
    addi a3, a3, 48
    sb a3, 2(s5)
    addi a4, a4, 48
    sb a4, 3(s5)
    li t0, 10
    sb t0, 4(s5)
    ret

confere_p1:
    xor t0, s1, a1              
    xor t0, s1, a2
    xor t0, s1, a4

    li t1, 85                   # mask t1 = 0b1010101
    and a5, t0, t1
    ret 

confere_p2:
    xor t0, s2, a1              
    xor t0, s2, a3
    xor t0, s2, a4

    li t1, 51                   # mask t1 = 0b0110011
    and a6, t0, t1 
    ret

confere_p3:
    xor t0, s3, a2              
    xor t0, s3, a3
    xor t0, s3, a4

    li t1, 15                   # mask t1 = 0b1111
    and a7, t0, t1 
    ret


write_encode:
    li a0, 1
    la a1, resultado
    li a2, 8
    li a7, 64
    ecall
    ret

write_decode:
    li a0, 1
    la a1, decodificado
    li a2, 5
    li a7, 64
    ecall
    ret

write_erro:
    li a0, 1
    la a1, erro 
    li a2, 2
    li a7, 64
    ecall
    ret
