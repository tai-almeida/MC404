.globl _start

_start:
    jal main

.text

.bss
input_adress: .skip 0x4000F
# altura: .word 0
# largura: .word 0

.data
input_file: .asciz "image.pgm"

main:
    /* 
       s0: arquivo PGM
       s1: conteudo lido no arquivo 
       s2: altura da imagem
       s3: largura da imagem
    */
    addi sp, sp, -4
    sw ra, (sp)
    jal open             # abre o arquivo - salvo em a0
    jal read             # le o conteudo do arquivo
    mv s1, a1            # guarda o conteudo em s1

    jal dimensiona       # guarda os valores de largura e altura da imagem
    jal setCanvasSize
    jal formata_imagem
    jal close

    li a0, 0
    li a7, 93
    ecall

open:
    la a0, input_file    # address for the file path
    li a1, 0             # flags (0: rdonly, 1: wronly, 2: rdwr)
    li a2, 0             # mode
    li a7, 1024          # syscall open
    ecall
    ret

read:
    la a1, input_adress
    li a2, 262159
    li a7, 63
    ecall
    ret

close:
    li a0, 3             # file descriptor (fd) 3
    li a7, 57            # syscall close
    ecall
    ret

dimensiona:
    addi s1, s1, 3       # salta para a segunda linha do cabecalho
    li t2, 10
    li s2, 0
    li s3, 0

    get_largura:
        lbu t0, 0(s1)     # armazena primeiro byte
        li t5, 32
        
        beq t0, t5, get_altura   # encontrou um espaco
        addi t0, t0, -48         # passa para inteiro
        

        mul s2, s2, t2           # multiplica s2 por 10 (posicionar digito)
        add s2, s2, t0

        addi s1, s1, 1           # incrementa ponteiro do input
        # addi s2, s2, 1           # incrementa ponteiro da largura

        j get_largura

    get_altura:
        addi s1, s1, 1
        lbu t1, 0(s1)
        li t5, 10
        beq t1, t5, end_dimensiona
        addi t1, t1, -48
        
        mul s3, s3, t2
        add s3, s3, t1

        # addi s3, s3, 1
        j get_altura
    
    
    end_dimensiona:
        addi s1, s1, 5
        ret

formata_imagem:
    addi sp, sp, -4
    sw ra, (sp)
    li a1, 0                # i = 0
    li a0, 0                # j = 0

    loop_colunas:
        bge a0, s2, prox_linha
        lbu a3, 0(s1)
        li a2, 0
        # addi a3, a3, -48            # converte byte para inteiro

        # Considera-se que a3 = R = G = B e Alpha = 255 sempre
        slli t2, a3, 24             # a2[31..24]: Red
        or a2, a2, t2

        slli t3, a3, 16             # a2[23..16]: Green
        or a2, a2, t3

        slli t4, a3, 8              # a2[15..8]: Blue
        or a2, a2, t4

        li t5, 255                  # a2[7..0]: Alpha 
        or a2, a2, t5


        jal setPixel

        addi s1, s1, 1
        addi a0, a0, 1              # j++

        j loop_colunas

    prox_linha:
        bge a1, s3, fim_matriz
        li a0, 0
        addi a1, a1, 1              # i++
        j loop_colunas
    
    fim_matriz:
        # addi s1, s1, 1
        lw ra, (sp)
        addi sp, sp, 4
        ret  

setPixel:
    li a7, 2200          # syscall setPixel (2200)
    ecall
    ret

setCanvasSize:
    mv a0, s2
    mv a1, s3
    li a7, 2201
    ecall
    ret
