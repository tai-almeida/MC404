.globl _start

_start:
    jal main                  # Salta para o rotulo main
    
.bss
resultado: .word              
linha_1: .space 12
linha_2: .space 20

.text
main:
    # s0: resultado
    # s1: entrada 1
    # s2: entrada 2
    # s3: counter loop
    # s4: Ta
    # s5: Tb
    # s6: Tc
    # s7: Tr
    # s8: x
    # s9: y
    addi sp, sp, -4
    sw ra, 0(sp)
    la s0, resultado          # guarda endereco do resultado
    la s1, linha_1
    jal read_1                  
    mv s1, a1                 # input em s1
    
    # ler os tempos
    li a1, 0
    li s2, 0
    li a2, 20
    la s2, linha_2
    jal read_2
    mv s2, a1
    li s3, 0
    loop:
        li t1, 20
        bge s3, t1, end_main
        jal tempo_decimal
        li t2, 0
        li t3, 5
        li t4, 10
        li t5, 15
        jal if
        addi s3, s3, 5
        j loop
    end_main:
        jal calcula_distancia
        jal to_string_x
        jal to_string_y
        li t6, 10             # '\n'
        sb t6, -1(s0)
        jal write

        li a0, 0
        li a7, 93
        ecall

read_1:
    li a0, 0                  # file descriptor = 0 (stdin)
    la a1, linha_1            #  buffer to write the data
    li a2, 12
    li a7, 63                 # syscall read (63)
    ecall
    ret

read_2:
    li a0, 0                  # file descriptor = 0 (stdin)
    la a1, linha_2            #  buffer to write the data
    li a2, 20
    li a7, 63                 # syscall read (63)
    ecall
    ret

calcula_distancia:
    addi sp, sp, -4
    sw ra, 0(sp)
    jal posicao_decimal       # passa coordenadas x para decimal
    mv a2, a0                 # Yb em a2
    addi s1, s1, 6            # avanca o ponteiro do input 6 posicoes
    
    li s8, 0
    li s9, 0

    # calcula da (guarda em t2)
    li t0, 3                  # velocidade da luz (c)
    li t1, 0
    li t2, 0
    li t3, 10

    # c = da/deltat
    # c = 3x10⁸ m/s = 0,3 m/nanosegundos
    sub t1, s7, s4            # deltat = Tr - Ta
    mul t2, t0, t1            # da = c*(Tr - Ta)
    div t2, t2, t3            # velocidade da luz em nanosegundos
    
    
    #calcuça db (guarda em t4)
    li t4, 0
    li t1, 0
    sub t1, s7, s5            # deltat = Tr - Tb
    mul t4, t1, t0            # db = c*(Tr - Tb)
    div t4, t4, t3

    # calcula dc            
    li t5, 0
    li t1, 0
    sub t1, s7, s6            # deltat = Tr - Tc
    mul t5, t1, t0            # db = c*(Tr - Tc)
    div t5, t5, t3

    # calcula y (guarda em s8)
    # y = (dA2 + YB2 - dB2) / 2YB
    li t0, 0
    li t1, 0
    li t3, 0
    li t6, 0

    mul t0, t2, t2            # t0 <- da²
    mul t1, a2, a2            # t1 <- Yb²
    mul t3, t4, t4            # t3 <- db²

    add t6, t0, t1            # t6 = da² +Yb²
    sub t6, t6, t3
    li t0, 0
    li t1, 2
    mul t0, a2, t1           # t0 = Yb * 2
    div t6, t6, t0
    mv s9, t6

    jal posicao_decimal       # passa coordenadas y para decimal
    mv a1, a0                 # Xc em a1

    # calcula x (guarda em s9)
    # x = (da²+Xc²-dc²)/2Xc
    li t0, 3
    li t1, 0
    li t3, 10

    sub t1, s7, s4            # deltat = Tr - Ta
    mul t2, t0, t1            # da = c*(Tr - Ta)
    div t2, t2, t3            # velocidade da luz em nanosegundos

    mul t0, t2, t2        # da²
    mul t1, a1, a1        # Xc²
    mul t3, t5, t5        # dc²

    add t6, t0, t1        # t6 = da² + Xc²
    sub t6, t6, t3        # t6 = (da² +Xc² - dc²)
    li t0, 0
    li t1, 2
    mul t0, a1, t1
    div t6, t6, t0        # t6 = (da² +Xc² - dc²)/2Xc
    mv s8, t6
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

posicao_decimal:
    /* Extrai as coordenadas dos pontos de entrada (s1) */
    li t0, 45
    li a5, 0
    li a0, 0

    lbu a0, 0(s1)             # armazena o sinal

    li t2, 1000
    lb a1, 1(s1)
    addi a1, a1, -48
    mul a1, a1, t2
    add a5, a5, a1

    li t2, 100
    lb a2, 2(s1)
    addi a2, a2, -48
    mul a2, a2, t2
    add a5, a5, a2

    li t2, 10
    lb a3, 3(s1)
    addi a3, a3, -48
    mul a3, a3, t2
    add a5, a5, a3

    lb a4, 4(s1)
    addi a4, a4, -48
    add a5, a5, a4

    beq t0, a0, then          # verifica se eh negativo
    li a0, 0
    mv a0, a5
    ret
then:
    li t1, -1             # valor negativo
    mul a5, a5, t1
    li a0, 0
    mv a0, a5
    ret 

tempo_decimal:
    li t5, 10
    li a4, 0

    lbu a0, 0(s2)             # armazena o primeiro digito da entrada em a0
    addi a0, a0, -48          # subtrai 48 do digito (ascii)
    li t2, 1000               # armazena o valor 10^3 em t2
    mul a0, a0, t2            # multiplica o valor em a0 pela potencia de 10
    add a4, a4, a0

    lbu a1, 1(s2)             # armazena o segundo digito da entrada em a1
    addi a1, a1, -48          # subtrai 48 do digito (ascii)
    li t2, 100                # divide a potencia por 10
    mul a1, a1, t2            # multiplica o valor em a0 pela potencia de 10
    add a4, a4, a1

    lbu a2, 2(s2)             # armazena o terceiro digito da entrada em a2
    addi a2, a2, -48          # subtrai 48 do digito (ascii)
    li t2, 10                 # divide a potencia por 10
    mul a2, a2, t2            # multiplica o valor em a0 pela potencia de 10
    add a4, a4, a2

    lbu a3, 3(s2)             # armazena o quarto digito da entrada em a3
    addi a3, a3, -48          # subtrai 48 do digito (ascii)
    li t2, 1                  # divide a potencia por 10
    mul a3, a3, t2            # multiplica o valor em a0 pela potencia de 10
    add a4, a4, a3

    addi s2, s2, 5
    ret

to_string_x:
    li t0, 0
    blt s8, t0, x_negativo        # if x < 0 then target
    j x_positivo
    x_negativo:
        li t1, -1
        li t2, 45
        sb t2, 0(s0)
        mul s8, s8, t1
        j continue
    x_positivo:
        li t2, 43
        sb t2, 0(s0)
        j continue

    continue:
        li t3, 1000                             

        div t4, s8, t3           # isola o quarto digito
        addi t4, t4, 48           # soma 48 ao digito isolado
        sb t4, 1(s0)              # armazena o byte em s0 (registrador armazena raiz)
        rem s8, s8, t3          # guarda o resto da divisão em s2

        li t3, 100                # terceiro digito
        div t4, s8, t3            
        addi t4, t4, 48          
        sb t4, 2(s0)              
        rem s8, s8, t3        

        li t3, 10                 # segundo digito
        div t4, s8, t3            
        addi t4, t4, 48     
        sb t4, 3(s0)      
        rem s8, s8, t3        

        li t3, 1                  # terceiro digito
        div t4, s8, t3            
        addi t4, t4, 48           
        sb t4, 4(s0)              
        rem s8, s8, t3 

        li t0, 32
        sb t0, 5(s0) 

        addi s0, s0, 6        
        ret

to_string_y:
    li t0, 0
    blt s9, t0, y_negativo        # if x < 0 then target
    j y_positivo
    y_negativo:
        li t1, -1
        li t2, 45
        sb t2, 0(s0)
        mul s9, s9, t1
        j continua
    y_positivo:
        li t2, 43
        sb t2, 0(s0)
        j continua

    continua:
        li t3, 1000                             

        div t4, s9, t3           # isola o quarto digito
        addi t4, t4, 48           # soma 48 ao digito isolado
        sb t4, 1(s0)              # armazena o byte em s0 (registrador armazena raiz)
        rem s9, s9, t3          # guarda o resto da divisão em s2

        li t3, 100                # terceiro digito
        div t4, s9, t3            
        addi t4, t4, 48          
        sb t4, 2(s0)              
        rem s9, s9, t3           

        li t3, 10                 # segundo digito
        div t4, s9, t3            
        addi t4, t4, 48     
        sb t4, 3(s0)      
        rem s9, s9, t3        

        li t3, 1                  # terceiro digito
        div t4, s9, t3            
        addi t4, t4, 48           
        sb t4, 4(s0)              
        rem s9, s9, t3

        li t0, 32
        sb t0, 5(s0)

        addi s0, s0, 6         
        ret

write:
    li a0, 1                  # a0: File descriptor = 1 (stdout)
    la a1, resultado          # buffer
    li a2, 20
    li a7, 64                 # Código da chamada (write = 64)
    ecall                     # Invocar o SO
    ret

if:
    beq s3, t2, caso1
    beq s3, t3, caso2
    beq s3, t4, caso3
    beq s3, t5, caso4
    ret

caso1:
    mv s4, a4
    ret

caso2:
    mv s5, a4
    ret

caso3:
    mv s6, a4
    ret

caso4:
    mv s7, a4
    ret
