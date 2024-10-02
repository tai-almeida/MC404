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
    jal cria_filtro
    jal aplica_filtro
    # jal imprime_imagem
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
    addi sp, sp, -8
    sw s4, 0(sp)
    sw ra, 4(sp)
    
    # Considera-se que a7 = R = G = B e Alpha = 255 sempre
    slli t2, a7, 24             # a2[31..24]: Red
    or a2, a2, t2

    slli t3, a7, 16             # a2[23..16]: Green
    or a2, a2, t3

    slli t4, a7, 8              # a2[15..8]: Blue
    or a2, a2, t4

    li t5, 255                  # a2[7..0]: Alpha 
    or a2, a2, t5
    lw s4, 0(sp)
    lw ra, 4(sp)
    addi sp, sp, 8
    ret  

cria_filtro:
    la s6, matriz_filtro
    li t0, -1
    li t1, 8
    sb t0, 0(s6)
    sb t0, 1(s6)
    sb t0, 2(s6)
    sb t0, 3(s6)
    sb t1, 4(s6)
    sb t0, 5(s6)
    sb t0, 6(s6)
    sb t0, 7(s6)
    sb t0, 8(s6)
    ret

aplica_filtro:
    addi sp, sp, -4
    sw ra, (sp)

    li a1, 0            # i = 0
    li a0, 0            # j = 0
    li t2, 0            # k = 0
    li t3, 0            # q = 0           
    li a2, 0
    li a5, 0
    li a6, 0
    li a3, 0
    li a4, 0

    loop_i:
        bge a1, s2, fim_filtro      # fim das linhas
        li a7, 0
        loop_j:
            bge a0, s3, next_line
            ble a1, a5, borda      # if i = 0
            bge a1, s2, borda     # if i >= x
            ble a0, a5, borda      # if j = 0
            bge a0, s3, borda     # if j >= y
            j loop_k
            borda:
                li a7, 0
                j prox_pixel
            loop_k:
                li t4, 3        # dimensao do filtro
                bge t2, t4, prox_pixel
                mv t1, a1
                add a1, a1, t2
                addi a1, a1, -1     # a1 <- i+k-1
                loop_q:
                    li t4, 3        # dimensao do filtro
                    bge t3, t4, pula_linha_filtro
                    mv t0, a0
                    
                    else:
                    add a0, a0, t3
                    addi a0, a0, -1     # a0 <- q+k-1
                    
                    # acessar indice de s4 = (i x largura) + j
                    # 0(s4) = (i+k-1) * largura + (j+q-1)
                    mul t5, a1, s3
                    add t5, t5, a0

                    
    
                    for_s1:
                        bge a3, t5, cont
                        addi s1, s1, 1
                        addi a3, a3, 1
                        j for_s1
                    
                    cont:
                        lbu t5, 0(s1)
                        lb t6, 0(s6)
                        mul t4, t5, t6      # pixel * filtro
                        add a6, a6, t4      # salva resultado em a6
                        jal verifica_valor      # verifica se valor esta entre 0 e 255
                        add a7, a7, a6
                        # addi s4, s4, 1      # avanca input
                        addi s6, s6, 1      # avanca filtro
                        addi t3, t3, 1      # q++
                        
                        j loop_q

            pula_linha_filtro:
                mv a1, t1
                mv a0, t0
                addi t2, t2, 1
                j loop_k
            prox_pixel:
                li t2, 0
                li t3, 0
                mv a1, t1
                mv a0, t0
                jal formata_imagem
                jal setPixel
                addi a0, a0, 1
                j loop_i
        next_line:
            addi a1, a1, 1
            li a0, 0
            j loop_i
    
    fim_filtro:
        lw ra, (sp)
        addi sp, sp, 4
        ret
 
verifica_valor:
    li t5, 255
    li t6, 0

    ble a6, t6, pixel_preto
    bge a6, t5, pixel_branco
    ret
    pixel_preto:
        li a6, 0
        ret
    pixel_branco:
        li a6, 255
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
