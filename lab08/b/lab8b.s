.globl _start

_start:
    jal main

.text

.bss
input_adress: .skip 0x4000F
matriz_input: .skip 0x40000       # tam max: 512 x 512
matriz_output: .skip 0x40000      # tam max: 512 x 512
matriz_filtro: .skip 0xa

.data
input_file: .asciz "image.pgm"

main:
    /* 
       s0: arquivo PGM
       s1: conteudo lido no arquivo 
       s2: altura da imagem
       s3: largura da imagem
       s4: matriz input
       s5: matriz output
       s6: matriz de filtro
    */
    addi sp, sp, -4
    sw ra, (sp)
    jal open             # abre o arquivo - salvo em a0
    jal read             # le o conteudo do arquivo
    mv s1, a1            # guarda o conteudo em s1

    jal dimensiona       # guarda os valores de largura e altura da imagem
    jal setCanvasSize
    jal aplica_filtro
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
        

        mul s3, s3, t2           # multiplica s2 por 10 (posicionar digito)
        add s3, s3, t0

        addi s1, s1, 1           # incrementa ponteiro do input
        j get_largura

    get_altura:
        addi s1, s1, 1
        lbu t1, 0(s1)
        li t5, 10
        beq t1, t5, end_dimensiona
        addi t1, t1, -48
        
        mul s2, s2, t2
        add s2, s2, t1

        j get_altura
    
    
    end_dimensiona:
        addi s1, s1, 5
        ret

formata_imagem:
    li a2, 0
    # Considera-se que a7 = R = G = B e Alpha = 255 sempre
    slli t2, a7, 24             # a2[31..24]: Red
    or a2, a2, t2

    slli t3, a7, 16             # a2[23..16]: Green
    or a2, a2, t3

    slli t4, a7, 8              # a2[15..8]: Blue
    or a2, a2, t4

    li t5, 255                  # a2[7..0]: Alpha 
    or a2, a2, t5
    ret  


aplica_filtro:
    addi sp, sp, -4
    sw ra, (sp)

    li a1, 0            # i = 0
    li a0, 0            # j = 0
    li a5, 0
    li a6, 0
    addi a3, s2, -1
    addi a4, s3, -1

    loop_i:
        bge a1, s2, fim_filtro      # fim das linhas
        
        loop_j:
            li a7, 0
            if_borda:
                    ble a1, a5, borda      # if i = 0
                    bge a1, a3, borda     # if i >= x
                    ble a0, a5, borda      # if j = 0
                    bge a0, a4, borda     # if j >= y
                    j cont
                borda:
                    li a7, 0
                    bge a0, s3, next_line
                    j prox_pixel
            cont:
                bge a0, s3, next_line
                # pega todos os valores vizinhos da matriz de entrada
                li t1, -1
                li t2, 8
                sub t6, s1, s3
                # linha superior
                lbu t0, -1(t6)
                sub a7, a7, t0
                lbu t0, 0(t6)
                sub a7, a7, t0
                lbu t0, 1(t6)
                sub a7, a7, t0

                # posicao atual
                lbu t0, 0(s1)
                slli t0, t0, 3
                add a7, a7, t0
                lbu t0, -1(s1)
                sub a7, a7, t0
                lbu t0, 1(s1)
                sub a7, a7, t0

                # embaixo esquerda
                add t6, s1, s3
                lbu t0, -1(t6)
                sub a7, a7, t0
                lbu t0, 0(t6)
                sub a7, a7, t0
                lbu t0, 1(t6)
                sub a7, a7, t0
                
                jal verifica_valor
                j prox_pixel
        prox_pixel:
            jal formata_imagem
            jal setPixel
            addi a0, a0, 1
            addi s1, s1, 1
            j loop_j
        next_line:
            addi a1, a1, 1
            li a0, 0
            j loop_i
    
    fim_filtro:
        lw ra, (sp)
        addi sp, sp, 4
        ret
 
verifica_valor:
    li t5, 256
    li t6, 0

    ble a7, t6, pixel_preto
    bge a7, t5, pixel_branco
    ret
    pixel_preto:
        li a7, 0
        ret
    pixel_branco:
        li a7, 255
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
