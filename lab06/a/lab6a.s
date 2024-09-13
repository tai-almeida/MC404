.globl _start

_start:
    jal main                  # Salta para o rotulo main
    

.bss
raiz: .skip 0x20              
input_address: .skip 0x20     

.text
main:
    la s0, raiz               # armazena a raiz no registrador s0
    jal read                  # le a entrada
    mv s1, a1
    la s1, input_address      # armazena o endereço do buffer de input 
    li s5, 0                  # i = 0
    li s6, 20                 # limite do for i = 4
    
loop:                         # loop para cada 4 digitos da entrada
    bge s5, s6, end           # if i >= 4, end
    jal para_decimal          # passa 4 digitos para decimal
    jal calcula_raiz          # calcula o valor da raiz
    jal to_string             # armazena o valor calculado como string
    addi s5, s5, 5            # i += 5
    addi s1, s1, 5            # avança o contador do input 5 bytes
    addi s0, s0, 5
    j loop                    # repete o loop

end:
    li s7, 10
    sb s7, -1(s0)             # '\n'
    jal write                 # imprime resultado
    li a0, 0
    li a7, 93
    ecall


read:
    li a0, 0                  # file descriptor = 0 (stdin)
    la a1, input_address      #  buffer to write the data
    li a2, 20                 # size (reads only 1 byte)
    li a7, 63                 # syscall read (63)
    ecall
    ret

para_decimal:
    li t5, 10
    li a4, 0

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
    
    mv s2, a4                 # armazena o valor decimal no registrador s2
    ret

calcula_raiz:
    li t0, 0
    li t1, 0
    li t2, 2
    li t3, 0
    li t4, 10
    li t5, 0
    div t6, s2, t2           # chute inicial: metade do decimal obtido da entrada

loop_raiz:
    bge t3, t4, continua      # if a0 >= 10: continua         
    div t5, s2, t6            # t5 recebe y/k
    add t6, t6, t5            # a2 = k + y/k
    div t6, t6, t2            # t7 = (k + y/k) / 2
    addi t3, t3, 1            # i++
    j loop_raiz               # retoma o loop

continua:
    mv s3, t6
    ret

to_string:
    li t3, 1000                             

    div t4, s3, t3            # isola o quarto digito
    addi t4, t4, 48           # soma 48 ao digito isolado
    sb t4, 0(s0)              # armazena o byte em s0 (registrador armazena raiz)
    rem s3, s3, t3            # guarda o resto da divisão em s2
    #addi t2, t2, 1           # move o ponteiro

    li t3, 100                # terceiro digito
    div t4, s3, t3            
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
