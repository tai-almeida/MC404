.globl _start

.bss
raiz: .skip 0x20              # inicializa com zero   
input_address: .skip 0x20     # buffer

.text

main:
    la s0, raiz               # armazena a raiz no registrador s0
    la s1, input_address      # endereco do buffer de input
    jal read                  # le a entrada
    li s5, 0                  # i = 0
    li s6, 20                 # limite do for i = 4
    
    loop:                         # loop para cada 4 digitos da entrada
        bge s5, s6, end           # if i >= 4, end
        jal para_decimal          # passa 4 digitos para decimal
        jal calcula_raiz          # calcula o valor da raiz
        jal to_string             # armazena o valor calculado como string
        addi s5, s5, 5            # i += 5
        addi s1, s1, 5            # avança o contador do input 5 bytes
        j loop                    # repete o loop

    end:
        li s7, 10
        sb s7, 19(s0)             # output[19] = '\n'
        jal write                 # imprime resultado
        ret


read:
    li a0, 0                  # file descriptor = 0 (stdin)
    la a1, input_address      #  buffer to write the data
    li a2, 20                 # size (reads only 1 byte)
    li a7, 63                 # syscall read (63)
    ecall
    ret

para_decimal:
    li a4, 0
    li t5, 10

    lbu a0, 0(s1)             # armazena o primeiro digito da entrada em a0
    addi a0, a0, -48          # subtrai 48 do digito (ascii)
    li t2, 1000               # armazena o valor 10^3 em t2
    mul a0, a0, t2            # multiplica o valor em a0 pela potencia de 10
    add a4, a4, a0


    lbu a1, 1(s1)             # armazena o segundo digito da entrada em a1
    addi a1, a1, -48          # subtrai 48 do digito (ascii)
    li t2, 100                # divide a potencia por 10
    mul a1, a1, t2            # multiplica o valor em a0 pela potencia de 10
    add a4, a4, a1

    lbu a2, 2(s1)             # armazena o terceiro digito da entrada em a2
    addi a2, a2, -48          # subtrai 48 do digito (ascii)
    li t2, 10                 # divide a potencia por 10
    mul a2, a2, t2            # multiplica o valor em a0 pela potencia de 10
    add a4, a4, a2

    lbu a3, 3(s1)             # armazena o quarto digito da entrada em a3
    addi a3, a3, -48          # subtrai 48 do digito (ascii)
    li t2, 1                  # divide a potencia por 10
    mul a3, a3, t2            # multiplica o valor em a0 pela potencia de 10
    add a4, a4, a3
    
    li s2, 0
    mv s2, a4                 # armazena o valor decimal no registrador s2
    ret

calcula_raiz:
    li t6, 2
    li a0, 0                  # i = 0
    li a1, 10                 # limite 10 iteracoes
    li t5, 0
    divu a2, s2, t6           # chute inicial: metade do decimal obtido da entrada

loop_raiz:
    bge a0, a1, continua      # if a0 >= 10: continua         
    div t5, s2, a2            # t5 recebe y/k
    add a2, a2, t5            # a2 = k + y/k
    div a2, a2, t6            # t7 = (k + y/k) / 2
    addi a0, a0, 1            # i++
    j loop_raiz               # retoma o loop

continua:
    mv s3, a2
    ret

to_string:
    la t2, raiz               # endereço do buffer
    li t3, 1000              
    li t5, 10                

    div t4, s3, t3            # isola o quarto digito
    addi t4, t4, 48           # soma 48 ao digito isolado
    sb t4, 0(s0)              # armazena o byte em s0 (registrador armazena raiz)
    rem s3, s3, t3            # guarda o resto da divisão em s2
    #addi t2, t2, 1           # move o ponteiro

    li t3, 100                # terceiro digito
    div t4, s2, t3            
    addi t4, t4, 48          
    sb t4, 1(s0)              
    rem s3, s3, t3
    #addi t2, t2, 1            

    li t3, 10                 # segundo digito
    div t4, s3, t3            
    addi t4, t4, 48     
    sb t4, 2(s0)      
    rem s3, s3, t3
    #addi t2, t2, 1         

    li t3, 1                  # terceiro digito
    div t4, s3, t3            
    addi t4, t4, 48           
    sb t4, 3(s0)              
    rem s3, s3, t3
    #addi t2, t2, 1  

    li t0, 32
    sb t0, 4(s0)          
    ret

write:
    li a0, 1                  # a0: File descriptor = 1 (stdout)
    la a1, raiz               # buffer
    li a2, 20                 # syze
    li a7, 64                 # Código da chamada (write = 64)
    ecall                     # Invocar o SO
    ret

_start:
    jal main                  # Salta para o rotulo main
    li a0, 0
    li a7, 93
    ecall

# 0400 5337 2240 9166
# 1708 9816 8519 4815
# 0529 0087 0173 0597
# 0628 0279 0803 0508


