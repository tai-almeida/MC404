int read(int __fd, const void *__buf, int __n){
    int ret_val;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall write code (63) \n"
    "ecall               # invoke syscall \n"
    "mv %0, a0           # move return value to ret_val\n"
    : "=r"(ret_val)  // Output list
    : "r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
  return ret_val;
}

void write(int __fd, const void *__buf, int __n)
{
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write (64) \n"
    "ecall"
    :   // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
}

void exit(int code)
{
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (64) \n"
    "ecall"
    :   // Output list
    :"r"(code)    // Input list
    : "a0", "a7"
  );
}
#define STDIN_FD  0
#define STDOUT_FD 1
int resultado=0;
char input[31], input1[6], input2[6], input3[6], input4[6], input5[6];

/* Converte a string de entrada para o seu valor numerico */
int para_decimal(char *input) {
    int n_bytes = 6;
    int resultado=0, sinal=1;
    // verifica se eh negativo
    int j=0;
    if(input[0] == '-') {
        sinal =-1;
        j++;
    } else j++;

    // converte para inteiro
    int digito, potencia=1;
    for(int i=n_bytes-2; i>=j; i--) {
        digito = input[i] - '0';
        resultado += digito*potencia;
        potencia *= 10;
    }

    return resultado*sinal;
}

/* Seleciona os n digitos menos significativo
concatena esses digitos no resultado final a partir da posicao inicio
da direita para esquerda (menos para mais significativo)*/
void para_binario_lsb(int valor, int n, int inicio) {
    //int posicoes = 32-n;
    int lsb = valor & n;
    resultado |= (lsb << inicio);
}

/* Converte o valor para uma string representando o hexadecimal*/
void hex_code(int valor){
    char hex[11];
    unsigned int uval = (unsigned int) valor, aux;

    hex[0] = '0';
    hex[1] = 'x';
    hex[10] = '\n';

    for (int i = 9; i > 1; i--){
        aux = uval % 16;
        if (aux >= 10)
            hex[i] = aux - 10 + 'A';
        else
            hex[i] = aux + '0';
        uval = uval / 16;
    }
    write(STDOUT_FD, hex, 11);
    //printf("%s\n", hex);
}

/* Divide a entrada em 5 inputs de mesmo tamanho */
void formata_entrada() {
  for(int i=0; i<5; i++) {
    input1[i] = input[i];
    input2[i] = input[i+6];
    input3[i] = input[i+12];
    input4[i] = input[i+18];
    input5[i] = input[i+24];
  }
  input1[5] = '\0';
  input2[5] = '\0';
  input3[5] = '\0';
  input4[5] = '\0';
  input5[5] = '\0';
}

int main() {
    int valor_numerico=0;
    int n_bytes = read(STDIN_FD, input, 31);
    formata_entrada();
    
    // primeiro input - alocado a partir da posicao 0
    valor_numerico = para_decimal(input1);
    para_binario_lsb(valor_numerico, 7, 0); // 7: valor com 3 lsb = 1 e restante zero

    // segundo input - alocado a partir da posicao 3
    valor_numerico = para_decimal(input2);
    para_binario_lsb(valor_numerico, 255, 3); // 255: valor com 8 lsb = 1 e restante zero

    // terceiro input - alocado a partir da posicao 11
    valor_numerico = para_decimal(input3);
    para_binario_lsb(valor_numerico, 31, 11); // 31: valor com 5 lsb = 1 e restante zero

    // quarto input - alocado a partir da posicao 16
    valor_numerico = para_decimal(input4);
    para_binario_lsb(valor_numerico, 31, 16); // 31: valor com 5 lsb = 1 e restante zero

    // quinto input - alocado a partir da posicao 21
    valor_numerico = para_decimal(input5);
    para_binario_lsb(valor_numerico, 2047, 21); // 2047: valor com 11 lsb = 1 e restante zero

    hex_code(resultado);
    return 0;
}

void _start()
{
  int ret_code = main();
  exit(ret_code);
}