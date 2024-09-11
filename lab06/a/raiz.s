.text
.globl _start

_start:
    jal main                  # Salta para o rotulo main



main:
    la s0, raiz               # armazena a raiz no registrador s0
    jal read                  # le a entrada
    li t0, 0                  # i = 0
    li t1, 4                  # limite do for i = 4
    mv a0, s1                 # salva o conteudo de a0 (input) no registrador s1

    
    loop:                     # loop para cada 4 digitos da entrada
        bge t0, t1, continue  # if i >= 4, continue
        jal para_decimal      # passa 4 digitos para decimal
        jal calcula_raiz      # calcula o valor da raiz
        jal to_string         # armazena o valor calculado como string


    
    continue:
        # TODO: implementar



para_decimal:
    li a4, 0

    lb a0, 0(s1)              # armazena o primeiro digito da entrada em a0
    addi a0, a0, -48          # subtrai 48 do digito (ascii)
    li t2, 1000               # armazena o valor 10^3 em t2
    mul a0, a0, t2            # multiplica o valor em a0 pela potencia de 10
    addi a4, a4, a0


    lb a1, 1(s1)              # armazena o segundo digito da entrada em a1
    addi a1, a1, -48          # subtrai 48 do digito (ascii)
    div t2, t2, 10            # divide a potencia por 10
    mul a1, a1, t2            # multiplica o valor em a0 pela potencia de 10
    addi a4, a4, a1

    lb a2, 2(s1)              # armazena o terceiro digito da entrada em a2
    addi a2, a2, -48          # subtrai 48 do digito (ascii)
    div t2, t2, 10            # divide a potencia por 10
    mul a2, a2, t2            # multiplica o valor em a0 pela potencia de 10
    addi a4, a4, a2

    lb a3, 3(s1)              # armazena o quarto digito da entrada em a3
    addi a3, a3, -48          # subtrai 48 do digito (ascii)
    div t2, t2, 10            # divide a potencia por 10
    mul a3, a3, t2            # multiplica o valor em a0 pela potencia de 10
    addi a4, a4, a3
    
    mv a4, s2                 # armazena o valor decimal no registrador s2
    ret

to_string:
    li t3, 1000
    div t4, s2, t3
    addi s0, t4, 48


calcula_raiz:
    li a0, 0                  # i = 0
    li a1, 10                 # limite 10 iteracoes
    li a2, 0                  # armazena chute inicial da raiz em a2
    div a2, s2, 2             # chute inicial: metade do decimal obtido da entrada
    li a3, 0                  # calculo da raiz em a8
    li t5, 0 
    li t6, 0
    li t7, 0

    loop_raiz:
        bge a0, a1, continua  # if a0 >= 10: continua           
        div t5, s2, a2        # t5 recebe y/k
        addi t6, a2, t5       # t6 = k + y/k
        div t7, t6, 2         # t7 = (k + y/k) / 2
        addi, a0, a0, 1       # i++
    

    continua:
        mv a3, s0
        ret


write:
    li a0, 1                  # a0: File descriptor = 1 (stdout)
    la a1, input_address      # a1: endereço do buffer input_address
    li a2, 20                 # a2: tamanho do buffer input_address (20 bytes)
    li a7, 64                 # Código da chamada (write = 64)
    ecall                     # Invocar o SO
    ret

read:
    li a0, 0                  # file descriptor = 0 (stdin)
    la a1, input_address      #  buffer to write the data
    li a2, 20                 # size (reads only 1 byte)
    li a7, 63                 # syscall read (63)
    ecall
    ret

.bss
raiz: .skip 0x20              # inicializa com zero   
input_address: .skip 0x20     # buffer

