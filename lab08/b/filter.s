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
        j get_largura

    get_altura:
        addi s1, s1, 1
        lbu t1, 0(s1)
        li t5, 10
        beq t1, t5, end_dimensiona
        addi t1, t1, -48
        
        mul s3, s3, t2
        add s3, s3, t1

        j get_altura
    
    
    end_dimensiona:
        addi s1, s1, 5
        ret

formata_imagem:
    addi sp, sp, -4
    sw ra, (sp)
    li a1, 0                # i = 0
    li a0, 0                # j = 0
    li t1, 0                # k = 0
    li t0, 0                # l = 0

    loop_colunas:
        bge a0, s2, prox_linha
        lbu a3, 0(s1)       # carrega byte da memoria para a3
        sb a3, 0(s4)        # armazena byte na memoria em uma matriz
        li a2, 0

        # Considera-se que a3 = R = G = B e Alpha = 255 sempre
        slli t2, a3, 24             # a2[31..24]: Red
        or a2, a2, t2

        slli t3, a3, 16             # a2[23..16]: Green
        or a2, a2, t3

        slli t4, a3, 8              # a2[15..8]: Blue
        or a2, a2, t4

        li t5, 255                  # a2[7..0]: Alpha 
        or a2, a2, t5

        sb a2, 0(s5)                # armazena byte na matriz de output
        # jal setPixel

        addi s1, s1, 1
        addi s4, s4, 1
        addi a0, a0, 1              # j++
        addi t0, t0, 1              # l++

        j loop_colunas

    prox_linha:
        bge a1, s3, fim_matriz
        li a0, 0
        li t0, 0
        addi a1, a1, 1              # i++
        addi t1, t1, 1              # k++
        j loop_colunas
    
    fim_matriz:
        lw ra, (sp)
        addi sp, sp, 4
        ret  

cria_filtro:
    la s6, matriz_filtro
    li t2, 3
    li t4, -1
    li t5, 8
    li t0, 0
    li t1, 9
    mv t0, s7
    
    1:
        bge t0, t1, 2f
        sb t4, 0(t0)
        addi t0, t0, 1
        j 1b
    2:
        sb t5, 4(t0)
        mv s6, t0
        ret
    

aplica_filtro:
    la s6, matriz_output
    li a1, 0            # i = 0
    li a0, 0            # j = 0
    li t2, 0            # k = 0
    li t3, 0            # q = 0
    
    li t1, 0
    addi t4, s3, -1     # t4 = largura - 1
    addi t5, s2, -1     # t5 = altura - 1

    1:
        li t0, 2
        bge t3, t0, 2f      # q >= 3, proxima linha

        add t5, a1, t2
        addi t5, t5, -1     # t5 <- i + k - 1
        add t6, a0, t3
        addi t6, t6, -1     # t6 <- j + q - 1
        jal pixel_preto     # pixel preto nas bordas
        bne a3, t1, cont    # o pixel foi pintado de preto
        
        # multiplicar o byte convertido pra int pelo filtro
        lbu t0, 0(s4)
        lb t1, 0(s6)
        addi t0, t0, -48
        mul a2, t0, t1


        # avanca os ponteiros
        addi s4, s4, 1
        addi s6, s6, 1
        addi t3, t3, 1

        cont:
            j 1b

    2:
        bge t2, t0, 3f      # k >= 3, sai do loop
        li t3, 0
        addi t2, t2, 1      
        j 1b

    3:
        # TODO: implementar
    
    



setPixel:
    li a7, 2200          # syscall setPixel (2200)
    ecall
    ret

pixel_preto:
        li a7, 48
        li a3, 0
        bge t6, a5, 0f      # t6 >= largura da matriz
        ble t6, a1, 1f      # t6 <= 0
        ble t5, a1, 2f      # t5 <= 0
        bge t5, a6, 3f      # t5 >= altura da matriz
        ret
        0:
            addi t6, s3, -1
            sb a7, 0(s5)
            addi s4, s4, 1
            li a3, 1
            ret
        1:
            li t6, 48
            sb t6, 0(s5)
            addi s4, s4, 1
            li a3, 1
            ret
        2: 
            li t5, 48
            sb t5, 0(s5)
            addi s4, s4, 1
            li a3, 1
            ret

        3:
            addi t5, s2, -1
            sb a7, 0(s5)
            addi s4, s4, 1
            li a3, 1
            ret

setCanvasSize:
    mv a0, s2
    mv a1, s3
    li a7, 2201
    ecall
    ret
